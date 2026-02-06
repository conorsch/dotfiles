//! Homelab library - common configuration values and utilities.

pub mod gatus;
pub mod repo;

/// Path to incoming media directory.
pub const MEDIA_DIR: &str = "/mnt/Valhalla/Media/incoming";

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
