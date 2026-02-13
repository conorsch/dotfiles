use clap::{Parser, Subcommand};
use homelab::{
    MEDIA_GAMING_DIR, MEDIA_SERVER_ADDRESS, MEDIA_SERVER_TRANSFER_UPLOAD_URL, PUBLIC_GAMING_DIR,
    TRANSFER_VOLUME_DIR,
};
use tracing::{error, info};
use xshell::{cmd, Shell};

/// Substring indicating a file has been processed by "extract-clip".
const CLIP_SUBSTRING: &str = "clip";

#[derive(Parser)]
#[command(name = "gaming-vids")]
#[command(version = env!("CARGO_PKG_VERSION"))]
#[command(about = "Tool for organizing and reviewing gaming clips")]
struct Args {
    #[command(subcommand)]
    command: Commands,

    /// How recent the videos must be to be included
    #[arg(long, default_value = "1d", alias = "changed-within")]
    time_range: String,

    /// Media server hostname for remote operations
    #[arg(long, default_value = MEDIA_SERVER_ADDRESS)]
    media_server: String,

    /// Directory paths for searching for media to upload from Windows.
    #[arg(long)]
    windows_media_paths: Option<Vec<String>>,

    /// Whether to verify file checksums when copying from remote
    #[arg(long)]
    checksum: bool,
}

/// Check if the current system is running under WSL
fn is_wsl() -> Result<bool, Box<dyn std::error::Error>> {
    let sh = Shell::new()?;
    let output = cmd!(sh, "hostnamectl status --json pretty").output()?;
    let stdout = String::from_utf8(output.stdout)?;
    Ok(stdout.contains("WSL"))
}

fn get_default_windows_media_paths() -> Vec<String> {
    // Check for Windows captures directory
    let windows_gamebar_dir = format!(
        "/mnt/c/Users/{}/Videos/Captures",
        std::env::var("USER").unwrap_or_else(|_| "conor".to_string())
    );
    let nvidia_shadow_dir = format!(
        "/mnt/c/Users/{}/Videos/NVIDIA",
        std::env::var("USER").unwrap_or_else(|_| "conor".to_string())
    );
    vec![windows_gamebar_dir, nvidia_shadow_dir]
        .into_iter()
        .filter(|path| std::path::Path::new(path).exists())
        .collect()
}

#[derive(Subcommand)]
enum Commands {
    /// Upload game clips from Windows WSL
    Upload {
        /// Show which files would be uploaded without actually uploading
        #[arg(long)]
        dry_run: bool,
    },
    /// Organize videos on the remote server
    #[clap(alias = "org", alias = "reorg", alias = "reorganize")]
    Organize,
    /// Sync videos to local directory
    #[clap(alias = "synchronize")]
    Sync,
    /// Review videos by playing them
    Review,
    /// List video files
    #[clap(alias = "recent", alias = "ls")]
    List {
        /// List files on the remote server instead of locally
        #[arg(short, long)]
        remote: bool,
    },
    /// Archive all Windows media files to a tar file
    Archive,
    /// Publish recent clips to public gaming directory
    Publish {
        /// Show which files would be published without actually copying
        #[arg(long)]
        dry_run: bool,

        /// Substring for selecting files to publish
        ///
        /// The "clip" substring denotes that the script "extract-clip" was run on it;
        /// selecting for it means that we're only publishing clips that have already been edited.
        #[arg(long, default_value = CLIP_SUBSTRING)]
        substring: String,
    },
    /// Watch recent videos in VLC
    #[clap(alias = "play")]
    Watch {
        /// Only include clips (files containing "clip" in their name)
        #[arg(short, long)]
        clips: bool,
    },
    /// Print the directory path for gaming videos
    Cd {
        /// Use the local review directory instead of the media server directory
        #[arg(short, long)]
        review: bool,
    },
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let args = Args::parse();

    match args.command {
        Commands::Upload { dry_run } => {
            let paths = args
                .windows_media_paths
                .unwrap_or_else(get_default_windows_media_paths);
            upload(args.time_range, paths, dry_run).await?
        }
        Commands::Organize => reorganize(args.media_server, args.time_range).await?,
        Commands::Sync => {
            reorganize(args.media_server, args.time_range.clone()).await?;
            sync(args.time_range, args.checksum).await?;
        }
        Commands::Review => review(args.time_range).await?,
        Commands::List { remote } => list(args.time_range, remote).await?,
        Commands::Archive => {
            let paths = args
                .windows_media_paths
                .unwrap_or_else(get_default_windows_media_paths);
            archive(paths).await?
        }
        Commands::Publish { dry_run, substring } => {
            publish(args.time_range, substring, dry_run).await?
        }
        Commands::Watch { clips } => watch(args.time_range, clips).await?,
        Commands::Cd { review } => cd(review).await?,
    }

    Ok(())
}

/// Upload a single file to the remote server
fn upload_file(file_path: &str) -> Result<String, Box<dyn std::error::Error>> {
    let file_path_obj = std::path::Path::new(file_path);

    // Get the basename and URL-encode it
    let filename = file_path_obj
        .file_name()
        .and_then(|f| f.to_str())
        .ok_or("Failed to get filename")?;

    let encoded_filename = urlencoding::encode(filename);
    let upload_url = format!("{}{}", MEDIA_SERVER_TRANSFER_UPLOAD_URL, encoded_filename);

    // Read file contents
    let file_contents = std::fs::read(file_path)?;

    // Upload file using reqwest blocking client
    let client = reqwest::blocking::Client::new();
    let response = client.put(&upload_url).body(file_contents).send()?;

    // Check for HTTP errors (raise for status)
    let response = response.error_for_status()?;

    // Get the response URL/body
    let response_text = response.text()?;

    Ok(response_text.trim().to_string())
}

async fn upload(
    time_range: String,
    windows_media_paths: Vec<String>,
    dry_run: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if dry_run {
        info!(
            "dry-run: listing clips from WSL (time_range: {})",
            time_range
        );
    } else {
        info!("uploading clips from WSL (time_range: {})", time_range);
    }

    let sh = Shell::new()?;

    // Check if we're in WSL
    if !is_wsl()? {
        error!("upload mode only supported under WSL");
        std::process::exit(1);
    }

    // Validate that at least one directory exists
    let existing_paths: Vec<String> = windows_media_paths
        .into_iter()
        .filter(|path| std::path::Path::new(path).exists())
        .collect();

    if existing_paths.is_empty() {
        error!("No valid video directories found");
        std::process::exit(2);
    }

    // Find all recent files from all directories
    info!("Finding recent videos (changed within {})", time_range);
    let find_output = cmd!(
        sh,
        "fd -t f -e mp4 . {existing_paths...} --changed-within {time_range}"
    )
    .output()?;

    if !find_output.status.success() {
        error!("Failed to find videos");
        std::process::exit(1);
    }

    let files: Vec<String> = String::from_utf8(find_output.stdout)?
        .lines()
        .map(|s| s.to_string())
        .filter(|s| !s.is_empty())
        .collect();

    let total = files.len();
    if total == 0 {
        info!("No videos found to upload");
        return Ok(());
    }

    info!("Found {} video(s) to upload", total);

    if dry_run {
        // Just list the files that would be uploaded
        for file in files.iter() {
            println!("{}", file);
        }
        info!("Dry run completed - {} file(s) would be uploaded", total);
        return Ok(());
    }

    // Upload each file with progress logging
    for (i, file) in files.iter().enumerate() {
        let filename = std::path::Path::new(file)
            .file_name()
            .and_then(|f| f.to_str())
            .unwrap_or(file);

        info!("Uploading {}/{}: {}", i + 1, total, filename);

        match upload_file(file) {
            Ok(response_url) => {
                info!("Uploaded successfully: {}", response_url);
            }
            Err(e) => {
                error!("Failed to upload {}: {}", filename, e);
                std::process::exit(1);
            }
        }
    }

    info!("Upload completed successfully - {} file(s) uploaded", total);

    // Send notification with hostname from env var
    let hostname = std::env::var("HOSTNAME").unwrap_or_else(|_| "unknown".to_string());
    let message = format!("Videos uploaded from {}", hostname);
    homelab::shout(&message)?;

    Ok(())
}

async fn reorganize(
    media_server: String,
    time_range: String,
) -> Result<(), Box<dyn std::error::Error>> {
    info!(
        "reorganizing uploaded clips on remote server: {} (time_range: {})",
        media_server, time_range
    );

    let sh = Shell::new()?;

    // Media server script to import uploaded gaming vids, for editing.
    // Assumes that files have already been uploaded via ruin.dev/give/,
    // then reorganizes via hardlinks to an import directory.
    let dest_dir = MEDIA_GAMING_DIR;
    let source_dir = TRANSFER_VOLUME_DIR;

    let reorganize_cmd = format!(
        "mkdir -p {dest_dir} && fd -t f -e mp4 . {source_dir} --changed-within {time_range} -x ln -f {{}} {dest_dir}/{{/}}"
    );

    cmd!(sh, "ssh {media_server} {reorganize_cmd}").run()?;

    info!("Organize completed successfully");
    Ok(())
}

// Utility to build a HOME-based path to vids dirs
fn local_vids_dir() -> std::path::PathBuf {
    let vids_dir = format!(
        "{}/vids",
        std::env::var("HOME").expect("failed to look up HOME env var")
    );
    std::path::PathBuf::from(vids_dir)
}

/// Copy remote video files to localhost, so they're reviewable quickly.
async fn sync(time_range: String, checksum: bool) -> Result<(), Box<dyn std::error::Error>> {
    info!("fetching clips newer than (time_range: {})", time_range);

    let sh = Shell::new()?;

    // Check if media directory is mounted
    let media_dir = MEDIA_GAMING_DIR;
    if !std::path::Path::new(media_dir).exists() {
        info!("Media directory not mounted, attempting to mount");
        // Try to mount media directory
        let mount_output = cmd!(sh, "homelab media-mount").output()?;

        if !mount_output.status.success() {
            error!("Failed to mount media directory");
            std::process::exit(1);
        }
        info!("Media directory mounted successfully");
    }

    // Copy recent MP4 videos from remote to local directory
    let checksum_opt = if checksum { "--checksum" } else { "" };
    let vids_path = local_vids_dir().display().to_string();
    info!("Syncing videos from {} to {}", media_dir, vids_path);
    let sync_cmd = format!(
        // "fd -t f -e mp4 . {media_dir} --changed-within {time_range} -X rsync -ah --info=progress2 {checksum_opt} {{}} {vids_path}"
        // We include .tar files as well, since they're likely bundles of gaming-vids uploaded together.
        "fd -t f -e mp4 -e tar . {media_dir} --changed-within {time_range} -X rsync -ah --info=progress2 {checksum_opt} {{}} {vids_path}"
    );
    cmd!(sh, "sh -c {sync_cmd}").run()?;

    info!("Sync completed successfully");
    Ok(())
}

async fn review(time_range: String) -> Result<(), Box<dyn std::error::Error>> {
    info!("playing recent clips (time_range: {})", time_range);

    let sh = Shell::new()?;

    // Play videos - use shell to properly handle pipes
    let vids_path = local_vids_dir().display().to_string();
    info!("Looking for videos in: {}", vids_path);

    let review_cmd = format!(
        "fd -t f -e mp4 . {vids_path} --changed-within {time_range} | sort -n | xargs -r -d '\\n' vlc 2>/dev/null"
    );
    cmd!(sh, "bash -l -c {review_cmd}").run()?;

    info!("Review completed");
    Ok(())
}

async fn list(time_range: String, remote: bool) -> Result<(), Box<dyn std::error::Error>> {
    let sh = Shell::new()?;

    // When running under WSL and not listing remote, check Windows media directories
    if !remote && is_wsl()? {
        let windows_media_paths = get_default_windows_media_paths();

        if windows_media_paths.is_empty() {
            info!("No Windows media directories found");
            return Ok(());
        }

        info!(
            "listing recent clips from Windows media directories (time_range: {})",
            time_range
        );

        // List files from all Windows media directories
        let list_cmd = format!(
            "fd -t f -e mp4 . {} --changed-within {} | sort -n",
            windows_media_paths.join(" "),
            time_range
        );
        cmd!(sh, "sh -c {list_cmd}").run()?;

        return Ok(());
    }

    let target_dir = if remote {
        MEDIA_GAMING_DIR.to_string()
    } else {
        local_vids_dir().display().to_string()
    };

    info!(
        "listing recent clips in {} (time_range: {})",
        target_dir, time_range
    );

    // Check if directory exists
    if !std::path::Path::new(&target_dir).exists() {
        info!("No videos directory found at: {}", target_dir);
        return Ok(());
    }

    let list_cmd = format!("fd -t f -e mp4 . {target_dir} --changed-within {time_range} | sort -n");
    cmd!(sh, "sh -c {list_cmd}").run()?;

    Ok(())
}

/// Publish recent clips from CWD to the public gaming directory.
async fn publish(
    time_range: String,
    substring: String,
    dry_run: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    info!(
        "publishing recent clips to {} (time_range: {})",
        PUBLIC_GAMING_DIR, time_range
    );

    let sh = Shell::new()?;

    let fd_filter = format!("fd -t f -e mp4 -e gif {substring} . --changed-within {time_range}");

    if dry_run {
        info!("Dry run: listing files that would be published");
        cmd!(sh, "sh -c {fd_filter}").run()?;
    } else {
        let publish_cmd =
            format!("{fd_filter} -X rsync -ah --info=progress2 {{}} {PUBLIC_GAMING_DIR}");
        cmd!(sh, "sh -c {publish_cmd}").run()?;
        info!("Publish completed successfully");
    }

    Ok(())
}

/// Watch recent videos from CWD in VLC.
async fn watch(time_range: String, clips: bool) -> Result<(), Box<dyn std::error::Error>> {
    info!("watching recent videos (time_range: {})", time_range);

    let sh = Shell::new()?;

    let clip_filter = if clips {
        CLIP_SUBSTRING.to_string()
    } else {
        String::new()
    };

    let watch_cmd = format!(
        "fd -t f -e mp4 '{clip_filter}' . --changed-within {time_range} | sort -n | xargs -r -d '\\n' vlc 2>/dev/null"
    );
    cmd!(sh, "sh -c {watch_cmd}").run()?;

    info!("Watch completed");
    Ok(())
}

async fn cd(review: bool) -> Result<(), Box<dyn std::error::Error>> {
    // Determine target directory based on review flag
    let target_dir = if review {
        // Use local vids directory for review
        local_vids_dir().display().to_string()
    } else {
        // Use media server directory by default
        MEDIA_GAMING_DIR.to_string()
    };

    // Check if the target directory exists
    if !std::path::Path::new(&target_dir).exists() {
        error!("Target directory does not exist: {}", target_dir);
        std::process::exit(1);
    }

    // Print the directory path to stdout (for use with shell: cd $(gaming-vids cd))
    println!("{}", target_dir);

    Ok(())
}

async fn archive(windows_media_paths: Vec<String>) -> Result<(), Box<dyn std::error::Error>> {
    info!("creating archive of all Windows media files");

    let sh = Shell::new()?;

    // Check if we're in WSL
    if !is_wsl()? {
        error!("archive mode only supported under WSL");
        std::process::exit(1);
    }

    // Validate that at least one directory exists
    let existing_paths: Vec<String> = windows_media_paths
        .into_iter()
        .filter(|path| std::path::Path::new(path).exists())
        .collect();

    if existing_paths.is_empty() {
        error!("No valid video directories found");
        std::process::exit(2);
    }

    // Create timestamp for archive name
    let timestamp = chrono::Local::now().format("%Y%m%d-%H%M%S");
    let archive_name = format!("gaming-vids-archive-{}.tar", timestamp);

    info!("Creating archive: {}", archive_name);

    // Create tar archive of all files in the directories
    cmd!(sh, "tar -cf {archive_name} {existing_paths...}").run()?;

    // Get archive size and display it
    let size_output = cmd!(sh, "du -h {archive_name}").output()?;
    let size_info = String::from_utf8(size_output.stdout)?;
    let size = size_info.split_whitespace().next().unwrap_or("unknown");

    info!(
        "Archive created successfully: {} (size: {})",
        archive_name, size
    );

    Ok(())
}
