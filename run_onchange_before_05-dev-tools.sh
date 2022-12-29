#!/bin/bash
# Install common dev utils.
set -eo pipefail


# bootstrap dev langs
# https://rustup.rs/
if [[ ! -e ~/.cargo ]] ; then
    echo "Getting rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# https://github.com/moovweb/gvm
if [[ ! -e ~/.gvm ]] ; then
    echo "Getting gvm..."
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    echo "Sourcing gvm config..."
    # shellcheck source=/dev/null
    source ~/.gvm/scripts/gvm
    latest_go="$(gvm listall | sed 's/ //g' | grep -P '^\s*go[\d.]+$' | sort -V | tail -n 1 )"
    if [[ -z "$latest_go" ]]; then
        >&2 echo "ERROR: Could not find latest go version"
        exit 1
    fi
    gvm install "$latest_go" -B
fi

# get asdf
if [[ ! -d "$HOME/.asdf" ]] ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
    # asdf install | rg 'plugin is not installed' | perl -lanE 'print $F[0]' | xargs -r -n1 asdf plugin add
fi

# install starship terminal prompt
# https://starship.rs/guide/#%F0%9F%9A%80-installation
source ~/.bashrc
if ! hash starship > /dev/null 2>&1 ; then
    mkdir -p ~/bin
    sh -s -- -b ~/bin -y < <(curl -sSfL https://starship.rs/install.sh)
fi
