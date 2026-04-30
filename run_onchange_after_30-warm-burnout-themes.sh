#!/bin/bash
# Install warm-burnout terminal themes from the upstream repo
# cloned via .chezmoiexternal.toml.
set -euo pipefail

repo="${HOME:?}/.config/warm-burnout"

install -Dm644 "$repo/ghostty/warm-burnout-dark"    "${HOME}/.config/ghostty/themes/warm-burnout-dark"
install -Dm644 "$repo/ghostty/warm-burnout-light"   "${HOME}/.config/ghostty/themes/warm-burnout-light"
install -Dm644 "$repo/zellij/warm-burnout-dark.kdl" "${HOME}/.config/zellij/themes/warm-burnout-dark.kdl"
