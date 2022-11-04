#!/bin/bash
set -euo pipefail

# install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"


chezmoi_bin="${HOME}/bin/chezmoi"

dotfiles_repo="https://git.ruin.dev/conor/dotfiles"
dotfiles_branch="main"

"$chezmoi_bin" init --force "$dotfiles_repo" --branch "$dotfiles_branch" --apply
