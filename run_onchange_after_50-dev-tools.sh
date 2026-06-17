#!/bin/bash
set -euo pipefail

# shellcheck source=dot_bashrc
source "${HOME:?}/.bashrc"
# vim config
gum spin --title "Syncing vim plugins... " \
  vim +PlugInstall +qall

