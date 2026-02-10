//! Media directory mount management.
//!
//! Mounts the shared media directory from the homelab server
//! over the private Innernet network, using either sshfs (default)
//! or NFS.

use anyhow::{Context, Result};
use clap::ValueEnum;
use colored::Colorize;
use xshell::{cmd, Shell};

use crate::MEDIA_SERVER_ADDRESS;

/// Mount protocol for the media directory.
#[derive(Clone, Debug, Default, ValueEnum)]
pub enum Protocol {
    /// FUSE-based SSH filesystem (userspace, no root for mount).
    #[default]
    Sshfs,
    /// Network File System (requires root for mount).
    Nfs,
}

impl std::fmt::Display for Protocol {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Protocol::Sshfs => write!(f, "sshfs"),
            Protocol::Nfs => write!(f, "nfs"),
        }
    }
}

/// Run the media-mount subcommand.
pub fn run(protocol: Protocol, mount_point: &str) -> Result<()> {
    let sh = Shell::new()?;
    let mount_dir = mount_point;

    ensure_mount_dir(&sh, mount_dir)?;

    if is_mounted(mount_dir)? {
        println!("{} {} is already mounted", "✓".green(), mount_dir);
        return Ok(());
    }

    println!(
        "{} Mounting {} via {}",
        "→".blue(),
        mount_dir,
        protocol.to_string().bold()
    );

    let remote = format!("{}:{}", MEDIA_SERVER_ADDRESS, mount_dir);

    match protocol {
        Protocol::Sshfs => {
            cmd!(sh, "sshfs -o reconnect {remote} {mount_dir}")
                .run()
                .context("Failed to mount via sshfs")?;
        }
        Protocol::Nfs => {
            cmd!(sh, "sudo mount -t nfs {remote} {mount_dir}")
                .run()
                .context("Failed to mount via NFS")?;
        }
    }

    println!("{} Mounted successfully", "✓".green());
    Ok(())
}

/// Create the mount point directory if it doesn't exist, with
/// appropriate ownership and permissions.
fn ensure_mount_dir(sh: &Shell, path: &str) -> Result<()> {
    let meta = std::fs::metadata(path);
    if meta.is_ok() {
        return Ok(());
    }

    println!("{} Creating mount directory {}", "→".blue(), path);
    cmd!(sh, "sudo mkdir -p {path}")
        .run()
        .context("Failed to create mount directory")?;

    let user = std::env::var("USER").context("USER environment variable not set")?;
    let ownership = format!("root:{}", user);
    cmd!(sh, "sudo chown {ownership} {path}")
        .run()
        .context("Failed to set ownership on mount directory")?;

    cmd!(sh, "sudo chmod 770 {path}")
        .run()
        .context("Failed to set permissions on mount directory")?;

    Ok(())
}

/// Check whether the mount point already has something mounted,
/// by inspecting whether it appears in the system mount table.
fn is_mounted(path: &str) -> Result<bool> {
    let mounts = std::fs::read_to_string("/proc/mounts").context("Failed to read /proc/mounts")?;
    Ok(mounts.lines().any(|line| {
        line.split_whitespace()
            .nth(1)
            .map(|mp| mp == path)
            .unwrap_or(false)
    }))
}
