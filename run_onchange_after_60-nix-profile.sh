#!/bin/bash
# Installs nixpkgs via a nix profile.
# vi: ft=bash
set -euo pipefail

# Include checksums for package files, to trigger a rerun.
# nix packages hash: {{ include "packages/nix.txt" | sha256sum }}
chezmoi_src_dir="$HOME/.local/share/chezmoi"
nixpkgs_txt="${chezmoi_src_dir}/packages/nix.txt"

# We filter out blank lines and comments.
sed -e '/^\s*$/d ; /^\s*#/d;' "$nixpkgs_txt" \
  | xargs -r -I{} echo "nixpkgs#{}" \
  | xargs -r nix profile install --quiet
