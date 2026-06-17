#!/bin/bash
set -euo pipefail

# shellcheck source=dot_bashrc
source "${HOME:?}/.bashrc"
# vim config
gum spin --title "Syncing vim plugins... " \
  vim +PlugInstall +qall

# configure a DRY AGENTS.md for all llm programs

mkdir -p \
  "${HOME:?}/.pi/agents" \
  "${HOME:?}/.config/opencode" \
  "${HOME:?}/.claude"

ln -s "${HOME:?}/.local/share/ruindev/AGENTS.md" -f "${HOME:?}/.claude/CLAUDE.md"
ln -s "${HOME:?}/.local/share/ruindev/AGENTS.md" -f "${HOME:?}/.pi/agents/AGENTS.md"
ln -s "${HOME:?}/.local/share/ruindev/AGENTS.md" -f "${HOME:?}/.config/opencode/AGENTS.md"
