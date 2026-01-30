use std::fs::{self, File};
use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use comfy_table::{modifiers::UTF8_ROUND_CORNERS, presets::UTF8_FULL, Cell, Color, Table};
use flate2::write::GzEncoder;
use flate2::Compression;
use tar::Builder;
use walkdir::WalkDir;
use xshell::{cmd, Shell};

use homelab::gatus::{fetch_statuses, filter_endpoints};
use homelab::{
    GATUS_API_URL, INNERNET_NETWORK, MEDIA_DIR, MEDIA_SERVER, MEDIA_SERVER_ADDRESS,
    MEDIA_SERVER_GIT_REPOS_PATH, MEDIA_SERVER_TRANSFER_UPLOAD_URL,
};

#[derive(Parser)]
#[command(name = "homelab", version, about = "Homelab management CLI")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Manage git repositories.
    Repo {
        /// List existing repositories.
        #[arg(short, long)]
        list: bool,

        /// Name of the repository to create.
        name: Option<String>,
    },

    /// Upload files to transfer.sh or via other methods.
    Give {
        /// Paths to upload (files or directories).
        #[arg(required = true)]
        paths: Vec<PathBuf>,

        /// Upload via rsync instead of HTTP.
        #[arg(short, long)]
        rsync: bool,

        /// Generate a magic-wormhole URL.
        #[arg(short, long)]
        wormhole: bool,

        /// Create a tarball of the paths before uploading.
        #[arg(short, long)]
        tar: bool,
    },

    /// Show status of monitored services.
    Status {
        /// Filter by site/service name.
        #[arg(short, long)]
        site: Option<String>,

        /// Filter by domain/hostname.
        #[arg(short, long)]
        domain: Option<String>,
    },

    /// Print configuration values.
    #[command(alias = "env")]
    Config {
        /// Output as bash export statements (source-able).
        #[arg(long)]
        bash: bool,

        /// Output as TOML.
        #[arg(long)]
        toml: bool,

        /// Output as JSON.
        #[arg(short, long)]
        json: bool,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Repo { list, name } => cmd_repo(list, name),
        Commands::Give {
            paths,
            rsync,
            wormhole,
            tar,
        } => cmd_give(paths, rsync, wormhole, tar),
        Commands::Status { site, domain } => cmd_status(site, domain),
        Commands::Config { bash, toml, json } => cmd_config(bash, toml, json),
    }
}

fn cmd_config(bash: bool, toml: bool, json: bool) -> Result<()> {
    let config = [
        ("MEDIA_SERVER", MEDIA_SERVER),
        ("MEDIA_SERVER_ADDRESS", MEDIA_SERVER_ADDRESS),
        ("INNERNET_NETWORK", INNERNET_NETWORK),
        ("MEDIA_DIR", MEDIA_DIR),
        (
            "MEDIA_SERVER_TRANSFER_UPLOAD_URL",
            MEDIA_SERVER_TRANSFER_UPLOAD_URL,
        ),
        ("MEDIA_SERVER_GIT_REPOS_PATH", MEDIA_SERVER_GIT_REPOS_PATH),
        ("GATUS_API_URL", GATUS_API_URL),
    ];

    if bash {
        for (key, value) in &config {
            println!("export {}={:?}", key, value);
        }
    } else if toml {
        println!("[homelab]");
        for (key, value) in &config {
            println!("{} = {:?}", key.to_lowercase(), value);
        }
    } else if json {
        let map: serde_json::Map<String, serde_json::Value> = config
            .iter()
            .map(|(k, v)| (k.to_string(), serde_json::Value::String(v.to_string())))
            .collect();
        println!("{}", serde_json::to_string_pretty(&map)?);
    } else {
        let mut table = Table::new();
        table
            .load_preset(UTF8_FULL)
            .apply_modifier(UTF8_ROUND_CORNERS)
            .set_header(vec![
                Cell::new("Variable").fg(Color::White),
                Cell::new("Value").fg(Color::White),
            ]);

        for (key, value) in &config {
            table.add_row(vec![Cell::new(key).fg(Color::Cyan), Cell::new(value)]);
        }

        println!("{table}");
    }

    Ok(())
}

fn cmd_repo(list: bool, name: Option<String>) -> Result<()> {
    let repos_path = Path::new(MEDIA_SERVER_GIT_REPOS_PATH);

    if list {
        if !repos_path.exists() {
            bail!("Git repos path does not exist: {}", repos_path.display());
        }

        let mut repos: Vec<_> = fs::read_dir(repos_path)?
            .filter_map(|e| e.ok())
            .filter(|e| e.path().is_dir())
            .map(|e| e.file_name().to_string_lossy().to_string())
            .collect();

        repos.sort();

        if repos.is_empty() {
            println!("No repositories found.");
        } else {
            println!("{}", "Repositories:".bold());
            for repo in repos {
                println!("  {}", repo);
            }
        }
        return Ok(());
    }

    let Some(name) = name else {
        bail!("Repository name required. Use -l/--list to list repositories.");
    };

    let repo_path = repos_path.join(&name);

    if repo_path.exists() {
        println!(
            "{} Repository already exists: {}",
            "✓".green(),
            repo_path.display()
        );
        return Ok(());
    }

    let sh = Shell::new()?;
    fs::create_dir_all(&repo_path)?;
    sh.change_dir(&repo_path);
    cmd!(sh, "git init --bare").run()?;

    println!(
        "{} Created bare repository: {}",
        "✓".green(),
        repo_path.display()
    );

    Ok(())
}

fn cmd_give(paths: Vec<PathBuf>, rsync: bool, wormhole: bool, tar: bool) -> Result<()> {
    // Validate all paths exist
    for path in &paths {
        if !path.exists() {
            bail!("Path does not exist: {}", path.display());
        }
    }

    // Collect files to upload (expanding directories)
    let files_to_upload = collect_files(&paths)?;

    if tar {
        let tarball = create_tarball(&paths)?;
        upload_file(&tarball, rsync, wormhole)?;
        fs::remove_file(&tarball)?;
    } else if rsync || wormhole {
        // rsync and wormhole can handle multiple files
        for file in &files_to_upload {
            upload_file(file, rsync, wormhole)?;
        }
    } else {
        // transfer.sh upload
        for file in &files_to_upload {
            upload_file(file, false, false)?;
        }
    }

    Ok(())
}

fn collect_files(paths: &[PathBuf]) -> Result<Vec<PathBuf>> {
    let mut files = Vec::new();

    for path in paths {
        if path.is_file() {
            files.push(path.clone());
        } else if path.is_dir() {
            for entry in WalkDir::new(path).into_iter().filter_map(|e| e.ok()) {
                if entry.file_type().is_file() {
                    files.push(entry.path().to_path_buf());
                }
            }
        }
    }

    if files.is_empty() {
        bail!("No files found to upload");
    }

    Ok(files)
}

fn create_tarball(paths: &[PathBuf]) -> Result<PathBuf> {
    let tarball_name = if paths.len() == 1 {
        let name = paths[0]
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "archive".to_string());
        format!("{}.tar.gz", name)
    } else {
        "archive.tar.gz".to_string()
    };

    let tarball_path = std::env::temp_dir().join(&tarball_name);
    let tar_file = File::create(&tarball_path)?;
    let encoder = GzEncoder::new(tar_file, Compression::default());
    let mut archive = Builder::new(encoder);

    for path in paths {
        let name = path
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "file".to_string());

        if path.is_file() {
            archive.append_path_with_name(path, &name)?;
        } else if path.is_dir() {
            archive.append_dir_all(&name, path)?;
        }
    }

    archive.finish()?;

    println!(
        "{} Created tarball: {}",
        "✓".green(),
        tarball_path.display()
    );

    Ok(tarball_path)
}

fn upload_file(path: &Path, rsync: bool, wormhole: bool) -> Result<()> {
    let sh = Shell::new()?;
    let path_str = path.to_string_lossy().to_string();

    if wormhole {
        println!("{} Sending via wormhole: {}", "→".blue(), path.display());
        cmd!(sh, "wormhole-rs send {path_str}").run()?;
    } else if rsync {
        println!("{} Uploading via rsync: {}", "→".blue(), path.display());
        let dest = MEDIA_SERVER_TRANSFER_UPLOAD_URL;
        cmd!(sh, "rsync -avP {path_str} {dest}").run()?;
    } else {
        println!(
            "{} Uploading to transfer.sh: {}",
            "→".blue(),
            path.display()
        );

        let file_name = path
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "file".to_string());

        let url = format!("{}{}", MEDIA_SERVER_TRANSFER_UPLOAD_URL, file_name);

        let file_content = fs::read(path).context("Failed to read file")?;

        let client = reqwest::blocking::Client::new();
        let response = client
            .put(&url)
            .body(file_content)
            .send()
            .context("Failed to upload file")?;

        if response.status().is_success() {
            let download_url = response.text()?;
            println!("{} Upload complete!", "✓".green());
            println!("{} {}", "URL:".bold(), download_url.trim());
        } else {
            bail!("Upload failed with status: {}", response.status());
        }
    }

    Ok(())
}

fn cmd_status(site: Option<String>, domain: Option<String>) -> Result<()> {
    let mut endpoints = fetch_statuses(GATUS_API_URL)?;

    // Apply filters
    if let Some(ref filter) = site {
        endpoints = filter_endpoints(endpoints, filter);
    }
    if let Some(ref filter) = domain {
        endpoints = filter_endpoints(endpoints, filter);
    }

    if endpoints.is_empty() {
        println!("No endpoints found matching the filter.");
        return Ok(());
    }

    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_header(vec![
            Cell::new("Status").fg(Color::White),
            Cell::new("Service").fg(Color::White),
            Cell::new("Group").fg(Color::White),
            Cell::new("Hostname").fg(Color::White),
            Cell::new("Uptime").fg(Color::White),
            Cell::new("Response").fg(Color::White),
        ]);

    for endpoint in &endpoints {
        let is_healthy = endpoint.is_healthy();
        let status_cell = if is_healthy {
            Cell::new("●").fg(Color::Green)
        } else {
            Cell::new("●").fg(Color::Red)
        };

        let uptime = format!("{:.1}%", endpoint.uptime_percent());
        let uptime_cell = if endpoint.uptime_percent() >= 99.0 {
            Cell::new(&uptime).fg(Color::Green)
        } else if endpoint.uptime_percent() >= 95.0 {
            Cell::new(&uptime).fg(Color::Yellow)
        } else {
            Cell::new(&uptime).fg(Color::Red)
        };

        let (hostname, response_time) = if let Some(result) = endpoint.latest_result() {
            (
                result.hostname.clone(),
                format!("{:.0}ms", result.duration_ms()),
            )
        } else {
            ("N/A".to_string(), "N/A".to_string())
        };

        table.add_row(vec![
            status_cell,
            Cell::new(&endpoint.name),
            Cell::new(&endpoint.group),
            Cell::new(&hostname),
            uptime_cell,
            Cell::new(&response_time),
        ]);
    }

    println!("{table}");

    // Summary
    let healthy_count = endpoints.iter().filter(|e| e.is_healthy()).count();
    let total_count = endpoints.len();

    if healthy_count == total_count {
        println!("\n{} All {} services operational", "✓".green(), total_count);
    } else {
        println!(
            "\n{} {}/{} services operational",
            "!".yellow(),
            healthy_count,
            total_count
        );
    }

    Ok(())
}
