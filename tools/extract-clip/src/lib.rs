use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use tracing::{debug, info};
use xshell::{cmd, Shell};

/// Convert a timestamp string (HH:MM:SS, MM:SS, or bare seconds) to total seconds.
pub fn time_to_seconds(t: &str) -> Result<u64> {
    let parts: Vec<&str> = t.split(':').collect();
    match parts.len() {
        3 => {
            let h: u64 = parts[0].parse().context("invalid hours")?;
            let m: u64 = parts[1].parse().context("invalid minutes")?;
            let s: u64 = parts[2].parse().context("invalid seconds")?;
            Ok(h * 3600 + m * 60 + s)
        }
        2 => {
            let m: u64 = parts[0].parse().context("invalid minutes")?;
            let s: u64 = parts[1].parse().context("invalid seconds")?;
            Ok(m * 60 + s)
        }
        1 => {
            let s: u64 = parts[0].parse().context("invalid seconds")?;
            Ok(s)
        }
        _ => bail!("invalid timestamp format: {t}"),
    }
}

/// Compute the destination path: same directory, "-clip" appended before extension.
pub fn dest_path(source: &Path) -> PathBuf {
    let stem = source.file_stem().unwrap_or_default().to_string_lossy();
    let ext = source.extension().unwrap_or_default().to_string_lossy();
    let new_name = if ext.is_empty() {
        format!("{stem}-clip")
    } else {
        format!("{stem}-clip.{ext}")
    };
    source.with_file_name(new_name)
}

/// Extract a clip from `source` into `dest`.
pub fn extract_clip(
    sh: &Shell,
    source: &Path,
    dest: &Path,
    start_time: &str,
    duration: &str,
    ff_start: Option<&str>,
    ff_stop: Option<&str>,
) -> Result<()> {
    // Remove destination if it exists (ffmpeg won't overwrite).
    if dest.exists() {
        debug!("removing existing destination: {}", dest.display());
        std::fs::remove_file(dest)?;
    }

    let source = source.to_str().context("non-utf8 source path")?;
    let dest = dest.to_str().context("non-utf8 dest path")?;

    info!("extracting video clip...");

    match (ff_start, ff_stop) {
        (Some(ffs), Some(ffe)) => {
            let start_sec = time_to_seconds(start_time)?;
            let ff_start_sec = time_to_seconds(ffs)?;
            let ff_end_sec = time_to_seconds(ffe)?;
            let duration_sec = time_to_seconds(duration)?;
            let end_sec = start_sec + duration_sec;

            // Build complex filter for 5x speedup in the fast-forward section.
            // atempo is limited to 2.0 per filter, so chain 2.0 * 2.5 = 5.0.
            let filter = format!(
                "[0:v]trim=start={start_sec}:end={ff_start_sec},setpts=PTS-STARTPTS[v1];\
                 [0:a]atrim=start={start_sec}:end={ff_start_sec},asetpts=PTS-STARTPTS[a1];\
                 [0:v]trim=start={ff_start_sec}:end={ff_end_sec},setpts=(PTS-STARTPTS)/5[v2];\
                 [0:a]atrim=start={ff_start_sec}:end={ff_end_sec},asetpts=PTS-STARTPTS,atempo=2.0,atempo=2.5[a2];\
                 [0:v]trim=start={ff_end_sec}:end={end_sec},setpts=PTS-STARTPTS[v3];\
                 [0:a]atrim=start={ff_end_sec}:end={end_sec},asetpts=PTS-STARTPTS[a3];\
                 [v1][a1][v2][a2][v3][a3]concat=n=3:v=1:a=1[outv][outa]"
            );

            cmd!(
                sh,
                "ffmpeg -i {source} -filter_complex {filter} -map [outv] -map [outa] -loglevel 0 {dest}"
            )
            .run()
            .context("ffmpeg fast-forward extraction failed")?;
        }
        _ => {
            cmd!(
                sh,
                "ffmpeg -i {source} -ss {start_time} -t {duration} -loglevel 0 {dest}"
            )
            .run()
            .context("ffmpeg extraction failed")?;
        }
    }

    info!("clip extracted: {dest}");
    Ok(())
}

/// Generate a GIF from a video clip using gifski.
pub fn make_gif(sh: &Shell, video: &Path) -> Result<PathBuf> {
    let gif_path = video.with_extension("gif");
    let video = video.to_str().context("non-utf8 video path")?;
    let gif = gif_path.to_str().context("non-utf8 gif path")?;

    info!("generating gif...");
    cmd!(
        sh,
        "gifski --output {gif} --height 700 --fps 30 --quality 80 {video}"
    )
    .run()
    .context("gifski failed")?;

    info!("gif created: {gif}");
    Ok(gif_path)
}

/// Open a file with VLC.
pub fn open_file(sh: &Shell, path: &Path) -> Result<()> {
    let path = path.to_str().context("non-utf8 path")?;
    info!("opening file with vlc...");
    cmd!(sh, "vlc {path}")
        .quiet()
        .run()
        .context("vlc failed")?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_time_to_seconds_hhmmss() {
        assert_eq!(time_to_seconds("01:02:03").unwrap(), 3723);
    }

    #[test]
    fn test_time_to_seconds_mmss() {
        assert_eq!(time_to_seconds("02:30").unwrap(), 150);
    }

    #[test]
    fn test_time_to_seconds_bare() {
        assert_eq!(time_to_seconds("90").unwrap(), 90);
    }

    #[test]
    fn test_dest_path() {
        assert_eq!(
            dest_path(Path::new("video.mp4")),
            PathBuf::from("video-clip.mp4")
        );
        assert_eq!(
            dest_path(Path::new("/tmp/my_vid.mkv")),
            PathBuf::from("/tmp/my_vid-clip.mkv")
        );
    }
}
