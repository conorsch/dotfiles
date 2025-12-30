use clap::{Parser, Subcommand};
use tracing::{error, info};
use xshell::{cmd, Shell};

#[derive(Parser)]
#[command(name = "gaming-vids")]
#[command(version = env!("CARGO_PKG_VERSION"))]
#[command(about = "Tool for organizing and reviewing gaming clips")]
struct Args {
    #[command(subcommand)]
    command: Option<Commands>,

    /// How recent the videos must be to be included
    #[arg(long, default_value = "1d", alias = "changed_within")]
    time_range: String,

    /// Media server hostname for remote operations
    #[arg(long, default_value = "adolin.ruindev.wg")]
    media_server: String,

    /// Whether to verify file checksums when copying from remote
    #[arg(long)]
    checksum: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Upload game clips from Windows WSL
    Upload,
    /// Reorganize videos on the remote server
    #[clap(alias = "reorg")]
    Reorganize,
    /// Sync videos to local directory
    #[clap(alias = "synchronize")]
    Sync,
    /// Review videos by playing them
    #[clap(alias = "play")]
    Review,
    /// List local video files
    #[clap(alias = "recent")]
    List,
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
        Some(Commands::Upload) => upload(args.time_range).await?,
        Some(Commands::Reorganize) => reorganize(args.media_server).await?,
        Some(Commands::Sync) => {
            reorganize(args.media_server).await?;
            sync(args.time_range, args.checksum).await?;
        }
        Some(Commands::Review) => review(args.time_range).await?,
        Some(Commands::List) => list(args.time_range).await?,
        None => {
            // Default sequence: reorganize -> sync -> review
            info!("Running default sequence: reorganize -> sync -> review");
            reorganize(args.media_server.clone()).await?;
            sync(args.time_range.clone(), args.checksum).await?;
            review(args.time_range).await?;
        }
    }

    Ok(())
}

async fn upload(time_range: String) -> Result<(), Box<dyn std::error::Error>> {
    info!("uploading clips from WSL (time_range: {})", time_range);

    let sh = Shell::new()?;

    // Check if we're in WSL
    let output = cmd!(sh, "hostnamectl status --json pretty").output()?;

    let stdout = String::from_utf8(output.stdout)?;
    if !stdout.contains("WSL") {
        error!("upload mode only supported under WSL");
        std::process::exit(1);
    }

    // Check for Windows captures directory
    let windows_dir = format!(
        "/mnt/c/Users/{}/Videos/Captures",
        std::env::var("USER").unwrap_or_else(|_| "conor".to_string())
    );

    info!("Looking for videos in: {}", windows_dir);

    if !std::path::Path::new(&windows_dir).exists() {
        error!("vids dir not found: {}", windows_dir);
        std::process::exit(2);
    }

    // Find all recent files first
    info!("Finding recent videos (changed within {})", time_range);
    let find_output = cmd!(sh, "fd . {windows_dir} --changed-within {time_range}").output()?;

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

    // Upload each file with progress logging
    for (i, file) in files.iter().enumerate() {
        let filename = std::path::Path::new(file)
            .file_name()
            .and_then(|f| f.to_str())
            .unwrap_or(file);

        info!("Uploading {}/{}: {}", i + 1, total, filename);

        let upload_result = cmd!(sh, "ruin-give {file}").run();

        if upload_result.is_err() {
            error!("Failed to upload: {}", filename);
            std::process::exit(1);
        }
    }

    info!("Upload completed successfully - {} file(s) uploaded", total);
    Ok(())
}

async fn reorganize(media_server: String) -> Result<(), Box<dyn std::error::Error>> {
    info!(
        "reorganizing uploaded clips on remote server: {}",
        media_server
    );

    let sh = Shell::new()?;

    // Media server script to import uploaded gaming vids, for editing.
    // Assumes that files have already been uploaded via ruin.dev/give/,
    // then reorganizes via hardlinks to an import directory.
    let dest_dir = "/mnt/Valhalla/Media/incoming/gaming";
    let source_dir = "/mnt/Valhalla/container-volumes-nfs/transfer";

    let reorganize_cmd = format!(
        "mkdir -p {dest_dir} && fd -t f -e mp4 . {source_dir} -x ln -f {{}} {dest_dir}/{{/}}"
    );

    cmd!(sh, "ssh {media_server} {reorganize_cmd}").run()?;

    info!("Reorganize completed successfully");
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
    let media_dir = "/mnt/Valhalla/Media/incoming/gaming";
    if !std::path::Path::new(media_dir).exists() {
        info!("Media directory not mounted, attempting to mount");
        // Try to mount media directory
        let mount_output = cmd!(sh, "media-mount").output()?;

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
        "fd -t f -e mp4 . {media_dir} --changed-within {time_range} -X rsync -a --info=progress2 {checksum_opt} {{}} {vids_path}"
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
    cmd!(sh, "sh -c {review_cmd}").run()?;

    info!("Review completed");
    Ok(())
}

async fn list(time_range: String) -> Result<(), Box<dyn std::error::Error>> {
    info!("listing recent clips (time_range: {})", time_range);

    let sh = Shell::new()?;

    let vids_path = local_vids_dir().display().to_string();

    // Check if directory exists
    if !local_vids_dir().exists() {
        info!("No videos directory found at: {}", vids_path);
        return Ok(());
    }

    let list_cmd = format!("fd -t f -e mp4 . {vids_path} --changed-within {time_range} | sort -n");
    cmd!(sh, "sh -c {list_cmd}").run()?;

    Ok(())
}
