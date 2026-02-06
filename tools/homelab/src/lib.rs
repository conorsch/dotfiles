//! Homelab library - common configuration values and utilities.

use anyhow::{bail, Context, Result};

pub mod gatus;
pub mod repo;

/// Path to incoming media directory.
pub const MEDIA_DIR: &str = "/mnt/Valhalla/Media/incoming";

/// Path to incoming gaming clips directory.
pub const MEDIA_GAMING_DIR: &str = "/mnt/Valhalla/Media/incoming/gaming";

/// Path to the music library (beets-managed).
pub const MEDIA_MUSIC_LIBRARY_DIR: &str = "/mnt/Valhalla/Media/Heimchen";

/// Path to the ripping staging area for new music imports.
pub const MEDIA_RIPPING_DIR: &str = "/mnt/Valhalla/Media/incoming/new-music/ripping";

/// Path to the container volumes NFS transfer directory.
pub const TRANSFER_VOLUME_DIR: &str = "/mnt/Valhalla/container-volumes-nfs/transfer";

/// Path to the public gaming directory.
pub const PUBLIC_GAMING_DIR: &str = "/mnt/Valhalla/container-volumes-nfs/public/gaming";

/// URL for transfer.sh-compatible file uploads.
pub const MEDIA_SERVER_TRANSFER_UPLOAD_URL: &str = "https://ruin.dev/give/";

/// Path to git repositories on the media server.
pub const MEDIA_SERVER_GIT_REPOS_PATH: &str = "/mnt/Valhalla/git-repos";

/// Gatus status API endpoint.
pub const GATUS_API_URL: &str = "https://status.ruin.dev/api/v1/endpoints/statuses";

/// Media server hostname.
pub const MEDIA_SERVER: &str = "adolin";

/// Media server address (innernet).
pub const MEDIA_SERVER_ADDRESS: &str = "adolin.ruindev.wg";

/// Innernet network name.
pub const INNERNET_NETWORK: &str = "ruindev.wg";

/// RuinDev Gitea instance URL.
pub const RUINDEV_URL: &str = "https://git.ruin.dev";

/// Codeberg user URL.
pub const CODEBERG_URL: &str = "https://codeberg.org/conorsch";

/// GitHub user URL.
pub const GITHUB_URL: &str = "https://github.com/conorsch";

/// Self-hosted ntfy notification endpoint.
pub const NTFY_URL: &str = "https://ntfy.ruin.dev/jawn";

/// Send a notification message to the self-hosted ntfy server.
pub fn shout(message: &str) -> Result<()> {
    let client = reqwest::blocking::Client::new();
    let response = client
        .post(NTFY_URL)
        .body(message.to_string())
        .send()
        .context("Failed to send notification to ntfy")?;

    if !response.status().is_success() {
        bail!("ntfy returned error status: {}", response.status());
    }

    Ok(())
}
