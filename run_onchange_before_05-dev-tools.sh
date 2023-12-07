#!/bin/bash
# Install common dev utils.
set -eo pipefail


# bootstrap dev langs
# https://rustup.rs/
if [[ ! -e ~/.cargo ]] ; then
    echo "Getting rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# get asdf
if [[ ! -d "$HOME/.asdf" ]] ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
fi

echo "Installing asdf plugins..."
grep -P '^\w+' ~/.tool-versions | cut -d' ' -f1 | xargs -I{} asdf plugin add {}

echo "Setting up starship..."
# install starship terminal prompt
# https://starship.rs/guide/#%F0%9F%9A%80-installation
# shellcheck source=/dev/null
source ~/.bashrc
if ! hash starship > /dev/null 2>&1 ; then
    mkdir -p ~/bin
    sh -s -- -b ~/bin -y < <(curl -sSfL https://starship.rs/install.sh)
fi
