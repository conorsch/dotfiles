#!/bin/bash
set -euo pipefail


# bootstrap dev langs
# https://rustup.rs/
echo "Getting rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# https://github.com/moovweb/gvm
echo "Getting gvm..."
rm -rf "$HOME/.gvm"
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm
gvm install $(gvm listall | grep -P '^\s*go\d' | sort -V | tail -n 1 ) -B

# get asdf
if [[ ! -d "$HOME/.asdf" ]] ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
    # asdf install | rg 'plugin is not installed' | perl -lanE 'print $F[0]' | xargs -r -n1 asdf plugin add
fi
