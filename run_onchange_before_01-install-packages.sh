#!/bin/bash
# Installs common packages. Supports recent
# Debian & Fedora.
set -e
set -u
set -o pipefail

debian_version="$(grep -i '^NAME="Debian' /etc/os-release 2> /dev/null || echo '')"
fedora_version="$(grep -i '^NAME="Fedora' /etc/os-release 2> /dev/null || echo '')"
pkg_manager="apt"
if [[ -n "$debian_version" ]]; then
    pkg_manager="apt"
elif [[ -n "$fedora_version" ]]; then
    pkg_manager="dnf"
else
    echo "ERROR: Unknown platform"
    exit 1
fi


chezmoi_src_dir="$HOME/.local/share/chezmoi"
pkgs_txt="${chezmoi_src_dir}/packages/${pkg_manager}.txt"
if [[ ! -e "$pkgs_txt" ]]; then
    echo "ERROR: cannot find '$pkgs_txt'"
    echo "PWD is: $PWD"
    exit 1
fi

echo "Updating repo lists..."
sudo "$pkg_manager" update -y

grep -vP '^#' < "$pkgs_txt" \
    | xargs -d '\n' \
    sudo "$pkg_manager" install -y

sudo "$pkg_manager" autoremove -y
