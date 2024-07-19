#!/bin/bash
# Install common dev utils.
set -eo pipefail

# Bootstrap Rust environment, via https://rustup.rs/
if [[ ! -e ~/.cargo ]] ; then
    echo "Getting rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
echo "Installing rust toolchains..."
# shellcheck source=/dev/null
source ~/.cargo/env
rustup component add rust-analyzer
rustup toolchain add nightly
rustup target add wasm32-unknown-unknown x86_64-unknown-linux-musl
rustup update

echo "Setting up starship..."
# install starship terminal prompt
# https://starship.rs/guide/#%F0%9F%9A%80-installation
# shellcheck source=/dev/null
source ~/.bashrc
if ! hash starship > /dev/null 2>&1 ; then
    mkdir -p ~/bin
    sh -s -- -b ~/bin -y < <(curl -sSfL https://starship.rs/install.sh)
fi

echo "Setting up alacritty..."
alacritty_theme_dir="${HOME:?}/.config/alacritty/themes"
if [[ ! -d "$alacritty_theme_dir" ]] ; then
    mkdir -p "$alacritty_theme_dir"
    git clone https://github.com/alacritty/alacritty-theme "$alacritty_theme_dir"
fi
# The alacritty package was already installed via another script, but only on workstations.
# Now we symlink it as `x-terminal-emulator` so that `i3-sensible-terminal`
# picks it up. This seems to work better than setting TERMINAL=alacritty.
if [[ -e /usr/bin/alacritty ]] ; then
    ln -s "/usr/bin/alacritty" -f "/usr/local/bin/x-terminal-emulator"
fi

# Install devbox, a nix shim. Requires at least `xz-utils`
# and `direnv`.
echo "Setting up devbox..."
if ! hash devbox > /dev/null 2>&1 ; then
    curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
fi
# On each update, devbox demands that several abstruse commands be run.
# Let's try to avoid prompts to do so interactively.
eval "$(devbox global shellenv --recompute)"
# refresh-global
