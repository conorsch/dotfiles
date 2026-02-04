//! Git repository management module.

use std::fs;
use std::path::Path;

use anyhow::{bail, Result};
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use dialoguer::MultiSelect;
use xshell::{cmd, Shell};

use crate::{CODEBERG_URL, GITHUB_URL, MEDIA_SERVER_GIT_REPOS_PATH, RUINDEV_URL};

/// Git hosting backend provider.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, ValueEnum)]
pub enum Backend {
    /// Local homelab git server (Valhalla/adolin).
    #[default]
    #[value(alias = "homelab", alias = "adolin")]
    Valhalla,
    /// RuinDev Gitea instance.
    #[value(alias = "gitea")]
    RuinDev,
    /// Codeberg.org (Forgejo)
    #[value(alias = "forgejo")]
    Codeberg,
    /// GitHub.com
    Github,
}

/// CLI tool type for remote git providers.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CliTool {
    /// GitHub CLI (gh)
    Gh,
    /// Gitea CLI (tea)
    Tea,
    /// Forgejo CLI (fj)
    Fj,
}

impl Backend {
    /// Get the base URL for this backend.
    pub fn url(&self) -> Option<&'static str> {
        match self {
            Backend::Valhalla => None, // Local filesystem
            Backend::RuinDev => Some(RUINDEV_URL),
            Backend::Codeberg => Some(CODEBERG_URL),
            Backend::Github => Some(GITHUB_URL),
        }
    }

    /// Get a human-readable name for this backend.
    pub fn display_name(&self) -> &'static str {
        match self {
            Backend::Valhalla => "Valhalla (local)",
            Backend::RuinDev => "RuinDev (Gitea)",
            Backend::Codeberg => "Codeberg (Forgejo)",
            Backend::Github => "GitHub",
        }
    }

    /// Get the CLI tool used for this backend.
    pub fn cli_tool(&self) -> Option<CliTool> {
        match self {
            Backend::Valhalla => None,
            Backend::RuinDev => Some(CliTool::Tea),
            Backend::Codeberg => Some(CliTool::Fj),
            Backend::Github => Some(CliTool::Gh),
        }
    }

    /// Get the tea login name for Gitea backends.
    /// Returns None for non-tea backends.
    pub fn tea_login(&self) -> Option<&'static str> {
        match self {
            Backend::RuinDev => Some("ruindev"),
            _ => None,
        }
    }

    /// Get the fj host for Forgejo backends.
    /// Returns None for non-fj backends.
    pub fn fj_host(&self) -> Option<&'static str> {
        match self {
            Backend::Codeberg => Some("codeberg.org"),
            _ => None,
        }
    }
}

/// Repo subcommands.
#[derive(Subcommand)]
pub enum RepoCommands {
    /// List repositories.
    Ls {
        /// Git hosting provider to list from.
        #[arg(short, long, default_value = "valhalla")]
        provider: Backend,
    },
    /// Create a new repository.
    Create(CreateArgs),
    /// Fork a repository to a target provider.
    Fork(ForkArgs),
    /// Clone repositories interactively.
    Clone,
}

/// Arguments for the create subcommand.
#[derive(Args)]
pub struct CreateArgs {
    /// Name of the repository to create.
    pub name: String,
    /// Git hosting provider.
    #[arg(short, long, default_value = "valhalla")]
    pub provider: Backend,
}

/// Arguments for the fork subcommand.
#[derive(Args)]
pub struct ForkArgs {
    /// URL of the repository to fork.
    pub url: String,
    /// Target git hosting provider.
    #[arg(short, long, default_value = "valhalla")]
    pub provider: Backend,
}

/// Run the repo subcommand.
pub fn run(command: RepoCommands) -> Result<()> {
    match command {
        RepoCommands::Ls { provider } => cmd_ls(provider),
        RepoCommands::Create(args) => cmd_create(args),
        RepoCommands::Fork(args) => cmd_fork(args),
        RepoCommands::Clone => cmd_clone(),
    }
}

/// List repositories from the specified provider.
fn cmd_ls(provider: Backend) -> Result<()> {
    let sh = Shell::new()?;

    match provider {
        Backend::Valhalla => {
            let repos_path = Path::new(MEDIA_SERVER_GIT_REPOS_PATH);

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
        }
        Backend::Github => {
            // Use gh CLI to list repositories
            println!(
                "{} Listing repositories from {}...",
                "→".blue(),
                provider.display_name()
            );
            cmd!(sh, "gh repo list --limit 100").run()?;
        }
        Backend::RuinDev => {
            // Use tea CLI with the ruindev login
            println!(
                "{} Listing repositories from {}...",
                "→".blue(),
                provider.display_name()
            );
            let login = provider.tea_login().unwrap_or("default");
            cmd!(sh, "tea repos list --login {login} --output simple").run()?;
        }
        Backend::Codeberg => {
            // Use fj CLI for Forgejo/Codeberg
            println!(
                "{} Listing repositories from {}...",
                "→".blue(),
                provider.display_name()
            );
            if let Some(host) = provider.fj_host() {
                cmd!(sh, "fj --host {host} user repos").run()?;
            } else {
                cmd!(sh, "fj user repos").run()?;
            }
        }
    }

    Ok(())
}

/// Create a new repository on the specified provider.
fn cmd_create(args: CreateArgs) -> Result<()> {
    let sh = Shell::new()?;
    let name = &args.name;

    match args.provider {
        Backend::Valhalla => {
            let repos_path = Path::new(MEDIA_SERVER_GIT_REPOS_PATH);
            let repo_path = repos_path.join(&args.name);

            if repo_path.exists() {
                println!(
                    "{} Repository already exists: {}",
                    "✓".green(),
                    repo_path.display()
                );
                return Ok(());
            }

            fs::create_dir_all(&repo_path)?;
            sh.change_dir(&repo_path);
            cmd!(sh, "git init --bare").run()?;

            println!(
                "{} Created bare repository: {}",
                "✓".green(),
                repo_path.display()
            );
        }
        Backend::Github => {
            // Use gh CLI to create repository (default to private)
            println!(
                "{} Creating repository '{}' on {}...",
                "→".blue(),
                name,
                args.provider.display_name()
            );
            cmd!(sh, "gh repo create {name} --private").run()?;
            println!("{} Created repository: {}", "✓".green(), name);
        }
        Backend::RuinDev => {
            // Use tea CLI with the ruindev login
            println!(
                "{} Creating repository '{}' on {}...",
                "→".blue(),
                name,
                args.provider.display_name()
            );
            let login = args.provider.tea_login().unwrap_or("default");
            cmd!(sh, "tea repos create --name {name} --login {login}").run()?;
            println!("{} Created repository: {}", "✓".green(), name);
        }
        Backend::Codeberg => {
            // Use fj CLI for Forgejo/Codeberg
            println!(
                "{} Creating repository '{}' on {}...",
                "→".blue(),
                name,
                args.provider.display_name()
            );
            if let Some(host) = args.provider.fj_host() {
                cmd!(sh, "fj --host {host} repo create {name}").run()?;
            } else {
                cmd!(sh, "fj repo create {name}").run()?;
            }
            println!("{} Created repository: {}", "✓".green(), name);
        }
    }

    Ok(())
}

/// Fork a repository to the target provider.
fn cmd_fork(args: ForkArgs) -> Result<()> {
    let sh = Shell::new()?;
    let url = &args.url;

    match args.provider {
        Backend::Valhalla => {
            let repos_path = Path::new(MEDIA_SERVER_GIT_REPOS_PATH);

            // Extract repo name from URL
            let repo_name = args
                .url
                .trim_end_matches('/')
                .rsplit('/')
                .next()
                .unwrap_or("repo")
                .trim_end_matches(".git");

            let repo_path = repos_path.join(repo_name);

            if repo_path.exists() {
                println!(
                    "{} Repository already exists: {}",
                    "✓".green(),
                    repo_path.display()
                );
                println!("  Skipping fork (idempotent).");
                return Ok(());
            }

            // Clone as bare repository
            println!("{} Forking {} to Valhalla...", "→".blue(), url);
            cmd!(sh, "git clone --bare {url} {repo_path}").run()?;

            println!("{} Forked to: {}", "✓".green(), repo_path.display());
        }
        Backend::Github => {
            // Use gh CLI to fork repository
            // gh repo fork expects a OWNER/REPO format or full URL
            println!(
                "{} Forking {} to {}...",
                "→".blue(),
                url,
                args.provider.display_name()
            );
            cmd!(sh, "gh repo fork {url} --clone=false").run()?;
            println!("{} Fork created on GitHub", "✓".green());
        }
        Backend::RuinDev => {
            // Use tea CLI to fork repository
            // tea repos fork works on the current repo context, or we can use migrate
            // For forking external repos, we use migrate which imports from URL
            println!(
                "{} Forking {} to {}...",
                "→".blue(),
                url,
                args.provider.display_name()
            );
            let login = args.provider.tea_login().unwrap_or("default");
            // tea repos migrate can import from a URL
            cmd!(sh, "tea repos migrate --login {login} --clone-addr {url}").run()?;
            println!("{} Fork/migration created on RuinDev", "✓".green());
        }
        Backend::Codeberg => {
            // Use fj CLI for Forgejo/Codeberg
            // fj repo fork takes a OWNER/REPO format
            println!(
                "{} Forking {} to {}...",
                "→".blue(),
                url,
                args.provider.display_name()
            );
            if let Some(host) = args.provider.fj_host() {
                cmd!(sh, "fj --host {host} repo fork {url}").run()?;
            } else {
                cmd!(sh, "fj repo fork {url}").run()?;
            }
            println!("{} Fork created on Codeberg", "✓".green());
        }
    }

    Ok(())
}

/// Interactively clone repositories.
fn cmd_clone() -> Result<()> {
    let repos_path = Path::new(MEDIA_SERVER_GIT_REPOS_PATH);

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
        println!("No repositories available to clone.");
        return Ok(());
    }

    let selections = MultiSelect::new()
        .with_prompt("Select repositories to clone")
        .items(&repos)
        .interact()?;

    if selections.is_empty() {
        println!("No repositories selected.");
        return Ok(());
    }

    let sh = Shell::new()?;

    for idx in selections {
        let repo_name = &repos[idx];
        let source = repos_path.join(repo_name);
        let dest = Path::new(repo_name);

        if dest.exists() {
            println!(
                "{} {} already exists locally, skipping.",
                "!".yellow(),
                repo_name
            );
            continue;
        }

        let source_str = source.to_string_lossy().to_string();
        println!("{} Cloning {}...", "→".blue(), repo_name);
        cmd!(sh, "git clone {source_str} {repo_name}").run()?;
        println!("{} Cloned {}", "✓".green(), repo_name);
    }

    Ok(())
}
