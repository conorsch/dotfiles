#!/usr/bin/env bash
set -euo pipefail

# config
dotfiles_repo="$(git remote get-url origin)"
dotfiles_branch="${DOTFILES_BRANCH:-main}"

# install to ~/.local/bin, because ~/bin is managed by chezmoi
mkdir -p "$HOME/.local/bin"

# install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin/"
chezmoi_bin="${HOME}/.local/bin/chezmoi"

# deploy
"$chezmoi_bin" init --force "$dotfiles_repo" --branch "$dotfiles_branch" --apply
