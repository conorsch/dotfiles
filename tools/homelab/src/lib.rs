//! Homelab library - common configuration values and utilities.

pub mod gatus;

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
