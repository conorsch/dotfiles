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
