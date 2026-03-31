use std::path::PathBuf;

use anyhow::Result;
use clap::Parser;
use tracing_subscriber::EnvFilter;
use xshell::Shell;

use extract_clip::{dest_path, extract_clip, make_gif, open_file};

#[derive(Parser)]
#[command(name = "extract-clip")]
#[command(version = env!("CARGO_PKG_VERSION"))]
#[command(about = "Extract a clip from a video file, with optional GIF and fast-forward")]
struct Args {
    /// Source video file
    video: PathBuf,

    /// Start time (HH:MM:SS, MM:SS, or seconds)
    start_time: String,

    /// Duration (HH:MM:SS, MM:SS, or seconds)
    duration: String,

    /// Generate a GIF from the clip
    #[arg(short, long)]
    gif: bool,

    /// Open the clip after extraction
    #[arg(short, long)]
    open: bool,

    /// Start of fast-forward section (5x speed)
    #[arg(long, alias = "ff-begin")]
    ff_start: Option<String>,

    /// End of fast-forward section (5x speed)
    #[arg(long, alias = "ff-end")]
    ff_stop: Option<String>,

    /// Maximum vertical resolution (e.g. 1440 for 1440p). Videos taller than
    /// this are downscaled, preserving aspect ratio. Set to 0 to disable.
    #[arg(long, default_value_t = 1440, alias = "max-res")]
    max_resolution: u32,

    /// Enable verbose (debug) logging
    #[arg(short, long)]
    verbose: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| {
            if args.verbose {
                EnvFilter::new("debug")
            } else {
                EnvFilter::new("info")
            }
        }))
        .with_writer(std::io::stderr)
        .init();

    let sh = Shell::new()?;
    let dest = dest_path(&args.video);

    extract_clip(
        &sh,
        &args.video,
        &dest,
        &args.start_time,
        &args.duration,
        args.ff_start.as_deref(),
        args.ff_stop.as_deref(),
        if args.max_resolution > 0 {
            Some(args.max_resolution)
        } else {
            None
        },
    )?;

    if args.gif {
        make_gif(&sh, &dest)?;
    }

    if args.open {
        open_file(&sh, &dest)?;
    }

    Ok(())
}
