use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use dialoguer::{Input, Select};
use std::path::PathBuf;
use xshell::{Shell, cmd};

/// Audio CD ripping and music synchronization tools
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Rip an audio CD album to FLAC files
    Rip {
        /// Artist name
        #[arg(short, long)]
        artist: Option<String>,

        /// Album name
        #[arg(short = 'A', long)]
        album: Option<String>,

        /// Release year
        #[arg(short, long)]
        year: Option<u16>,

        /// Album name (positional argument, alternative to --album)
        #[arg(value_name = "ALBUM")]
        album_positional: Option<String>,
    },
    /// Synchronize select albums from remote storage to local storage
    Sync {
        /// Source directory containing music library
        #[arg(short, long, default_value = "/mnt/Valhalla/Media/Heimchen")]
        source: PathBuf,

        /// Destination directory for synchronized music
        #[arg(short, long)]
        dest: Option<PathBuf>,

        /// Artists to synchronize (if not specified, uses default list)
        #[arg(value_name = "ARTIST")]
        artists: Vec<String>,
    },
    /// Push local ripping directory to remote media server
    Push {
        /// Media server address
        #[arg(short, long, default_value = "adolin.ruindev.wg")]
        server: String,

        /// Destination path on remote server
        #[arg(
            short,
            long,
            default_value = "/mnt/Valhalla/Media/incoming/new-music/ripping"
        )]
        dest: String,

        /// Local source directory (defaults to ~/music/ripping)
        #[arg(short = 'S', long)]
        source: Option<PathBuf>,

        /// Only push directories changed within this time period (e.g., "1d", "2h", "30m")
        #[arg(short = 'w', long, default_value = "1d")]
        changed_within: String,
    },
    /// Import albums using beets (must be run on Adolin)
    Import {
        /// Source directory containing albums to import
        #[arg(
            short,
            long,
            default_value = "/mnt/Valhalla/Media/incoming/new-music/ripping"
        )]
        source: PathBuf,

        /// Only import directories changed within this time period (e.g., "1d", "2h", "30m")
        #[arg(short = 'w', long, default_value = "1d")]
        changed_within: String,
    },
    /// Manually tag FLAC files with metadata
    Tag {
        /// Directory containing FLAC files to tag (if not specified, prompts for selection)
        #[arg(value_name = "DIRECTORY")]
        directory: Option<PathBuf>,
    },
    /// Split a combined FLAC file using a CUE file
    Split {
        /// Directory containing FLAC and CUE files (if not specified, prompts for selection)
        #[arg(value_name = "DIRECTORY")]
        directory: Option<PathBuf>,
    },
}

fn main() -> Result<()> {
    let args = Args::parse();

    match args.command {
        Commands::Rip {
            artist,
            album,
            year,
            album_positional,
        } => handle_rip(artist, album, year, album_positional),
        Commands::Sync {
            source,
            dest,
            artists,
        } => handle_sync(source, dest, artists),
        Commands::Push {
            server,
            dest,
            source,
            changed_within,
        } => handle_push(server, dest, source, changed_within),
        Commands::Import {
            source,
            changed_within,
        } => handle_import(source, changed_within),
        Commands::Tag { directory } => handle_tag(directory),
        Commands::Split { directory } => handle_split(directory),
    }
}

fn handle_rip(
    artist: Option<String>,
    album: Option<String>,
    year: Option<u16>,
    album_positional: Option<String>,
) -> Result<()> {
    // Determine if album was provided
    let album_provided = album.is_some() || album_positional.is_some();

    // Get album name from either --album flag or positional argument
    let album_name = if let Some(album) = album.or(album_positional) {
        album
    } else {
        // No album provided, prompt for artist, album, and year
        let artist: String = Input::new()
            .with_prompt("Artist name")
            .allow_empty(true)
            .interact_text()
            .context("Failed to read artist name")?;

        let album: String = Input::new()
            .with_prompt("Album name")
            .interact_text()
            .context("Failed to read album name")?;

        let year: String = Input::new()
            .with_prompt("Release year")
            .allow_empty(true)
            .interact_text()
            .context("Failed to read release year")?;

        let year_parsed = if year.is_empty() {
            None
        } else {
            Some(year.parse::<u16>().context("Invalid year format")?)
        };

        // If we got values from prompt, return early
        return rip_album(Some(artist).filter(|s| !s.is_empty()), album, year_parsed);
    };

    // Album was provided via arg, check if artist and year were also provided
    let artist_name = if let Some(artist) = artist {
        Some(artist)
    } else if album_provided {
        // Album was provided but artist wasn't - prompt for artist
        let artist: String = Input::new()
            .with_prompt("Artist name")
            .allow_empty(true)
            .interact_text()
            .context("Failed to read artist name")?;
        Some(artist).filter(|s| !s.is_empty())
    } else {
        None
    };

    let year = if let Some(year) = year {
        Some(year)
    } else if album_provided {
        // Album was provided but year wasn't - prompt for year
        let year: String = Input::new()
            .with_prompt("Release year")
            .allow_empty(true)
            .interact_text()
            .context("Failed to read release year")?;
        if year.is_empty() {
            None
        } else {
            Some(year.parse::<u16>().context("Invalid year format")?)
        }
    } else {
        None
    };

    rip_album(artist_name, album_name, year)
}

fn rip_album(artist_name: Option<String>, album_name: String, year: Option<u16>) -> Result<()> {
    let sh = Shell::new()?;

    // Set up paths
    let home = std::env::var("HOME").context("HOME environment variable not set")?;
    let ripping_dest_dir = PathBuf::from(home).join("music/ripping");

    let album_dir = match (&artist_name, year) {
        (Some(artist), Some(y)) => {
            ripping_dest_dir.join(format!("{} - {} ({})", artist, album_name, y))
        }
        (Some(artist), None) => ripping_dest_dir.join(format!("{} - {}", artist, album_name)),
        (None, Some(y)) => ripping_dest_dir.join(format!("{} ({})", album_name, y)),
        (None, None) => ripping_dest_dir.join(&album_name),
    };

    // Create album directory
    cmd!(sh, "mkdir -p {album_dir}").run()?;

    println!("📀 Ripping album -> '{}'", album_dir.display());

    // Change to album directory (cdparanoia writes to CWD)
    sh.change_dir(&album_dir);

    // Rip CD to WAV
    println!("Step 1/2: Ripping CD to WAV...");
    cmd!(sh, "cdparanoia -B")
        .run()
        .context("Failed to rip CD with cdparanoia")?;

    println!();

    // Convert WAV to FLAC
    println!("Step 2/2: Converting files to FLAC...");
    cmd!(sh, "fd -t f -e wav . {album_dir} -X flac --best")
        .run()
        .context("Failed to convert WAV files to FLAC")?;

    // Clean up WAV files
    cmd!(sh, "fd -t f -e wav . {album_dir} -X rm")
        .run()
        .context("Failed to clean up WAV files")?;

    println!(
        "✅ Ripped album: '{}' -> '{}'",
        album_name,
        album_dir.display()
    );

    // Send notification
    let _ = cmd!(sh, "ntfy-send")
        .arg(format!("Finished ripping album: '{}'", album_name))
        .ignore_stdout()
        .run();

    Ok(())
}

fn handle_sync(source: PathBuf, dest: Option<PathBuf>, artists: Vec<String>) -> Result<()> {
    let sh = Shell::new()?;

    // Use default artists if none provided
    let artists_to_sync = if artists.is_empty() {
        vec![
            "Sole".to_string(),
            "Sole & DJ Pain 1".to_string(),
            "Cloudkicker".to_string(),
        ]
    } else {
        artists
    };

    // Set up destination path
    let home = std::env::var("HOME").context("HOME environment variable not set")?;
    let music_dst_dir = dest.unwrap_or_else(|| PathBuf::from(home).join("music"));

    // Create destination directory
    cmd!(sh, "mkdir -p {music_dst_dir}").run()?;

    // Display what we're syncing
    println!("Synchronizing music for:");
    println!();
    for artist in &artists_to_sync {
        println!("\t * {}", artist);
    }
    println!();

    // Change to source directory for easier rsync
    sh.change_dir(&source);

    // Build rsync command with all artists
    println!("Synchronizing music...");
    let mut rsync_cmd = cmd!(sh, "rsync -ah --info=progress2");
    for artist in &artists_to_sync {
        rsync_cmd = rsync_cmd.arg(artist);
    }
    rsync_cmd = rsync_cmd.arg(&music_dst_dir);

    rsync_cmd
        .run()
        .context("Failed to synchronize music with rsync")?;

    println!("All artists copied");

    // Calculate and display directory size
    let du_output = cmd!(sh, "du -sh {music_dst_dir}")
        .read()
        .context("Failed to calculate directory size")?;

    if let Some(size) = du_output.split_whitespace().next() {
        println!("Music dir size: {}", size);
    }

    Ok(())
}

fn handle_push(
    server: String,
    dest: String,
    source: Option<PathBuf>,
    changed_within: String,
) -> Result<()> {
    let sh = Shell::new()?;

    // Set up source path (default to ~/music/ripping)
    let home = std::env::var("HOME").context("HOME environment variable not set")?;
    let ripping_dir = source.unwrap_or_else(|| PathBuf::from(&home).join("music/ripping"));

    // Verify source directory exists
    if !ripping_dir.exists() {
        anyhow::bail!(
            "Ripping directory does not exist: {}",
            ripping_dir.display()
        );
    }

    // Find directories changed within the specified time using fd
    let fd_output = cmd!(
        sh,
        "fd -t d --max-depth 1 --changed-within {changed_within} . {ripping_dir}"
    )
    .read()
    .context("Failed to find directories with fd")?;

    let dirs: Vec<&str> = fd_output.lines().filter(|line| !line.is_empty()).collect();

    if dirs.is_empty() {
        println!(
            "No directories changed within {} in {}",
            changed_within,
            ripping_dir.display()
        );
        return Ok(());
    }

    // Build remote destination (server:path)
    let remote_dest = format!("{}:{}", server, dest);

    println!(
        "📤 Pushing {} director{} changed within {} to {}",
        dirs.len(),
        if dirs.len() == 1 { "y" } else { "ies" },
        changed_within,
        remote_dest
    );

    let mut dir_names = Vec::new();
    for dir in &dirs {
        let dir_path = PathBuf::from(dir);
        if let Some(dir_name) = dir_path.file_name() {
            let name = dir_name.to_string_lossy().to_string();
            println!("  - {}", name);
            dir_names.push(name);
        }
    }

    // Change to ripping directory for easier rsync
    sh.change_dir(&ripping_dir);

    // Build rsync command with all directories
    let mut rsync_cmd = cmd!(sh, "rsync -ah --info=progress2");
    for dir_name in &dir_names {
        rsync_cmd = rsync_cmd.arg(dir_name);
    }
    rsync_cmd = rsync_cmd.arg(&remote_dest);

    rsync_cmd
        .run()
        .context("Failed to push to remote server with rsync")?;

    println!("✅ Successfully pushed to {}", remote_dest);

    Ok(())
}

fn handle_import(source: PathBuf, changed_within: String) -> Result<()> {
    let sh = Shell::new()?;

    // Check hostname
    let hostname = cmd!(sh, "hostname")
        .read()
        .context("Failed to get hostname")?
        .trim()
        .to_string();

    if hostname != "Adolin" {
        anyhow::bail!(
            "This command must be run on Adolin (current hostname: {})",
            hostname
        );
    }

    // Verify source directory exists
    if !source.exists() {
        anyhow::bail!("Source directory does not exist: {}", source.display());
    }

    // Find directories changed within the specified time using fd
    let fd_output = cmd!(
        sh,
        "fd -t d --max-depth 1 --changed-within {changed_within} . {source}"
    )
    .read()
    .context("Failed to find directories with fd")?;

    let mut dirs: Vec<PathBuf> = fd_output
        .lines()
        .filter(|line| !line.is_empty())
        .map(PathBuf::from)
        .collect();

    if dirs.is_empty() {
        println!(
            "No directories changed within {} in {}",
            changed_within,
            source.display()
        );
        return Ok(());
    }

    // Sort directories for consistent processing order
    dirs.sort();

    println!(
        "📦 Found {} album(s) changed within {} to import:",
        dirs.len(),
        changed_within
    );
    for dir in &dirs {
        println!("  - {}", dir.file_name().unwrap().to_string_lossy());
    }
    println!();

    // Import each directory with beet
    for (idx, dir) in dirs.iter().enumerate() {
        let dir_name = dir.file_name().unwrap().to_string_lossy();
        println!("[{}/{}] Importing: {}", idx + 1, dirs.len(), dir_name);

        cmd!(sh, "beet import {dir}")
            .run()
            .context(format!("Failed to import: {}", dir_name))?;

        println!();
    }

    println!("✅ Successfully imported all albums");

    Ok(())
}

fn handle_tag(directory: Option<PathBuf>) -> Result<()> {
    let sh = Shell::new()?;

    // Determine which directory to tag
    let album_dir = if let Some(dir) = directory {
        dir
    } else {
        // No directory provided, prompt user to select one from ~/music/ripping
        let home = std::env::var("HOME").context("HOME environment variable not set")?;
        let ripping_dir = PathBuf::from(&home).join("music/ripping");

        if !ripping_dir.exists() {
            anyhow::bail!(
                "Ripping directory does not exist: {}",
                ripping_dir.display()
            );
        }

        // Find directories in ripping_dir
        let fd_output = cmd!(sh, "fd -t d --max-depth 1 . {ripping_dir}")
            .read()
            .context("Failed to find directories")?;

        let dirs: Vec<PathBuf> = fd_output
            .lines()
            .filter(|line| !line.is_empty())
            .map(PathBuf::from)
            .collect();

        if dirs.is_empty() {
            anyhow::bail!("No directories found in {}", ripping_dir.display());
        }

        // Create selection list with directory names
        let dir_names: Vec<String> = dirs
            .iter()
            .filter_map(|d| d.file_name().map(|n| n.to_string_lossy().to_string()))
            .collect();

        let selection = Select::new()
            .with_prompt("Select directory to tag")
            .items(&dir_names)
            .interact()
            .context("Failed to get directory selection")?;

        dirs[selection].clone()
    };

    // Verify directory exists
    if !album_dir.exists() {
        anyhow::bail!("Directory does not exist: {}", album_dir.display());
    }

    // Check for FLAC files
    let flac_count = cmd!(sh, "fd -t f -e flac . {album_dir}")
        .read()
        .context("Failed to search for FLAC files")?
        .lines()
        .filter(|line| !line.is_empty())
        .count();

    if flac_count == 0 {
        anyhow::bail!("No FLAC files found in {}", album_dir.display());
    }

    println!(
        "📝 Tagging {} FLAC file(s) in {}",
        flac_count,
        album_dir.display()
    );
    println!();

    // Prompt for metadata
    let artist: String = Input::new()
        .with_prompt("Artist name")
        .interact_text()
        .context("Failed to read artist name")?;

    let album_name: String = Input::new()
        .with_prompt("Album name")
        .interact_text()
        .context("Failed to read album name")?;

    let release_year: String = Input::new()
        .with_prompt("Release year")
        .interact_text()
        .context("Failed to read release year")?;

    // Change to album directory
    sh.change_dir(&album_dir);

    // Get sorted list of FLAC files
    let files_output = cmd!(sh, "fd -t f -e flac")
        .read()
        .context("Failed to list FLAC files")?;

    let mut files: Vec<String> = files_output
        .lines()
        .filter(|line| !line.is_empty())
        .map(String::from)
        .collect();

    files.sort();

    // Set track numbers automatically based on alphabetical sort
    println!("Setting track numbers...");
    for (i, file) in files.iter().enumerate() {
        let track_num = (i + 1).to_string();
        cmd!(sh, "metaflac --set-tag=TRACKNUMBER={track_num} {file}")
            .run()
            .context(format!("Failed to set track number for {}", file))?;
    }

    // Prompt for track titles
    println!();
    println!("Enter track titles:");
    for file in &files {
        let track_title: String = Input::new()
            .with_prompt(format!("Track title for {}", file))
            .interact_text()
            .context("Failed to read track title")?;

        cmd!(sh, "metaflac --set-tag=TITLE={track_title} {file}")
            .run()
            .context(format!("Failed to set title for {}", file))?;
    }

    // Set year on all files
    println!();
    println!("Setting metadata...");
    cmd!(
        sh,
        "fd -t f -e flac -X metaflac --set-tag=YEAR={release_year}"
    )
    .run()
    .context("Failed to set year")?;

    // Set artist on all files
    cmd!(sh, "fd -t f -e flac -X metaflac --set-tag=ARTIST={artist}")
        .run()
        .context("Failed to set artist")?;

    // Set album name on all files
    cmd!(
        sh,
        "fd -t f -e flac -X metaflac --set-tag=ALBUM={album_name}"
    )
    .run()
    .context("Failed to set album name")?;

    println!();
    println!("✅ All tags set!");
    println!("Album can be found in: '{}'", album_dir.display());

    Ok(())
}

fn handle_split(directory: Option<PathBuf>) -> Result<()> {
    let sh = Shell::new()?;

    // Check if shnsplit is available
    if cmd!(sh, "which shnsplit").read().is_err() {
        anyhow::bail!("'shnsplit' command not found; install 'cuetools' and/or 'shntool'");
    }

    // Determine which directory to work with
    let work_dir = if let Some(dir) = directory {
        dir
    } else {
        // No directory provided, prompt user to select one from ~/music/ripping
        let home = std::env::var("HOME").context("HOME environment variable not set")?;
        let ripping_dir = PathBuf::from(&home).join("music/ripping");

        if !ripping_dir.exists() {
            anyhow::bail!(
                "Ripping directory does not exist: {}",
                ripping_dir.display()
            );
        }

        // Find directories in ripping_dir
        let fd_output = cmd!(sh, "fd -t d --max-depth 1 . {ripping_dir}")
            .read()
            .context("Failed to find directories")?;

        let dirs: Vec<PathBuf> = fd_output
            .lines()
            .filter(|line| !line.is_empty())
            .map(PathBuf::from)
            .collect();

        if dirs.is_empty() {
            anyhow::bail!("No directories found in {}", ripping_dir.display());
        }

        // Create selection list with directory names
        let dir_names: Vec<String> = dirs
            .iter()
            .filter_map(|d| d.file_name().map(|n| n.to_string_lossy().to_string()))
            .collect();

        let selection = Select::new()
            .with_prompt("Select directory to split")
            .items(&dir_names)
            .interact()
            .context("Failed to get directory selection")?;

        dirs[selection].clone()
    };

    // Verify directory exists
    if !work_dir.exists() {
        anyhow::bail!("Directory does not exist: {}", work_dir.display());
    }

    // Find CUE file in the directory
    let cue_output = cmd!(sh, "fd -t f -e cue . {work_dir}")
        .read()
        .context("Failed to search for CUE file")?;

    let cue_files: Vec<&str> = cue_output.lines().filter(|line| !line.is_empty()).collect();

    if cue_files.is_empty() {
        anyhow::bail!("No CUE file found in {}", work_dir.display());
    }

    if cue_files.len() > 1 {
        anyhow::bail!(
            "Found multiple CUE files in {}, expected exactly one",
            work_dir.display()
        );
    }

    let cue_file = cue_files[0];

    println!("📀 Splitting FLAC file using CUE: {}", cue_file);
    println!("Working directory: {}", work_dir.display());

    // Run shnsplit on FLAC files with the CUE file
    // -f: CUE file to use
    // -t: output file format (%n = track number, %t = track title)
    // -o: output format (flac)
    cmd!(
        sh,
        "fd -t f -e flac . {work_dir} -X shnsplit -f {cue_file} -t %n-%t -o flac"
    )
    .run()
    .context("Failed to split FLAC file with shnsplit")?;

    println!();
    println!("✅ Successfully split FLAC file!");
    println!("Output files in: '{}'", work_dir.display());

    Ok(())
}
