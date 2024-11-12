#!/bin/bash
# Perform ad-hoc cleanup of crufty legacy configs.
set -eo pipefail


# Migrated the gdm logic to lightdm, via `i3-setup` script.
rm -vf ~/bin/fedora-login-wallpaper

# Ensure bash_login does not exist, because its presence will prevent
# loading of ~/.bash_profile and ~/.profile.
rm -vf ~/.bash_login

# Remove old version of starship, installed before switch to home-manager.
rm -vf ~/.local/bin/starship

# Remove old version of k0sctl, previously managed via `.chezmoiexternal.toml`.
rm -vf ~/.local/bin/k0sctl
