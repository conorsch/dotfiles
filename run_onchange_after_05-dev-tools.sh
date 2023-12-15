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

# We need to source asdf directly, because bashrc/bash_profile
# don't support interactive shells. Should they?
echo "Installing asdf plugins..."
source ~/.asdf/asdf.sh
if ! hash asdf > /dev/null 2>&1 ; then
    >&2 echo "ERROR: asdf not found, but should be."
    exit 1
fi
# Make sure necessary plugins are installed, with `|| true` because command
# is not idempotent.
grep -P '^\w+' ~/.tool-versions | cut -d' ' -f1 | xargs -I{} asdf plugin add {} || true

echo "Setting up starship..."
# install starship terminal prompt
# https://starship.rs/guide/#%F0%9F%9A%80-installation
# shellcheck source=/dev/null
source ~/.bashrc
if ! hash starship > /dev/null 2>&1 ; then
    mkdir -p ~/bin
    sh -s -- -b ~/bin -y < <(curl -sSfL https://starship.rs/install.sh)
fi
