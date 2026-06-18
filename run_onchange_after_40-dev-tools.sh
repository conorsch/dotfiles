#!/bin/bash
set -euo pipefail

# shellcheck source=dot_bashrc
source "${HOME:?}/.bashrc"

# vim config
gum spin --title "Syncing vim plugins... " \
  vim +PlugInstall +qall

# pnpm config (required v10 -> v11)
pnpm config set global-bin-dir "${HOME:?}/.local/share/pnpm"
