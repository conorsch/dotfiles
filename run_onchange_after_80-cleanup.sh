#!/bin/bash
# Perform ad-hoc cleanup of crufty legacy configs.
set -euo pipefail


# Migrated the gdm logic to lightdm, via `i3-setup` script.
rm -vf ~/bin/fedora-login-wallpaper

# Ensure bash_login does not exist, because its presence will prevent
# loading of ~/.bash_profile and ~/.profile.
rm -vf ~/.bash_login

# Remove old version of starship, installed before switch to home-manager.
rm -vf ~/.local/bin/starship
rm -vf ~/starship

# Remove old version of k0sctl, previously managed via `.chezmoiexternal.toml`.
rm -vf ~/.local/bin/k0sctl

# Migrated to using `gifski` from nixpkgs, which makes building with
# --features=video much easier.
rm -vf ~/bin/gifski

# Renamed script `chrome-pl` -> `chrome-pp`
rm -vf ~/bin/chrome-pl

# Moved script ~/bin/i3volume -> ~/.local/bin/i3volume
rm -vf ~/bin/i3volume

# Remove heavy-handed alacritty overrides
if [[ -L /usr/local/bin/x-terminal-emulator ]] ; then
  rm -vf /usr/local/bin/x-terminal-emulator
fi

# Consolidated LLM tooling to "install-llms" script
rm -vf ~/bin/install-claude
rm -vf ~/bin/install-opencode

# Remove dangling reference to nix builds
test -L ~/result && rm -vf ~/result

# Remove bash scripts that have been written as rust CLIs
rm -vf ~/bin/gaming-vids
rm -vf ~/bin/ntfy-send

# Purge home-manager config
if hash home-manager > /dev/null 2>&1 && hash nix > /dev/null 2>&1 ; then
  nix run home-manager/release-25.05 -- uninstall
fi
