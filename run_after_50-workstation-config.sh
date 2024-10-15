#!/bin/bash
# Install developer tooling, but only those tools appropriate
# for an interactive graphical workstation.
set -eo pipefail


# shellcheck source=/dev/null
source ~/.bashrc
if is_workstation ; then
    >&2 echo "Workstation detected, applying configs..."
else
    >&2 echo "Not a workstation, skipping workstation configs..."
    exit 0
fi

echo "Setting up alacritty..."
alacritty_theme_dir="${HOME:?}/.config/alacritty/themes"
if [[ ! -d "$alacritty_theme_dir" ]] ; then
    mkdir -p "$alacritty_theme_dir"
    git clone https://github.com/alacritty/alacritty-theme "$alacritty_theme_dir"
fi

# The alacritty package was already installed via another script, but only on Fedora,
# which is a proxy for saying "likely a workstation"
# Now we symlink it as `x-terminal-emulator` so that `i3-sensible-terminal`
# picks it up. This seems to work better than setting `TERM=alacritty`.
if [[ -e /usr/bin/alacritty ]] ; then
    ln -s "/usr/bin/alacritty" -f "/usr/local/bin/x-terminal-emulator"
fi

echo "Setting up nix..."
# Install nix: https://nixos.org/download/
if ! hash nix > /dev/null 2>&1 ; then
    sh <(curl -L https://nixos.org/nix/install) --daemon
    # shellcheck source=/dev/null
    source ~/.bashrc
fi
