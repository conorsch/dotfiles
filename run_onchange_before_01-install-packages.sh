#!/bin/bash
# Installs common packages. Supports recent
# Debian & Fedora.
set -eo pipefail

debian_version="$(grep -i '^NAME="Debian' /etc/os-release 2> /dev/null || echo '')"
fedora_version="$(grep -i '^NAME="Fedora' /etc/os-release 2> /dev/null || echo '')"
pkg_manager="apt"
admin_group="sudo"
if [[ -n "$debian_version" ]]; then
    pkg_manager="apt"
    admin_group="sudo"

elif [[ -n "$fedora_version" ]]; then
    pkg_manager="dnf"
    admin_group="wheel"
else
    echo "ERROR: Unknown platform"
    exit 1
fi

# Check whether we're running under QubesOS. If so, handle `curl` -> `curl-minimal`
# conflict via `--allowerasing` arg to dnf.
dnf_opts=""
if printenv | grep -q ^QUBES && [[ -n "$fedora_version" ]]; then
	dnf_opts="--allowerasing"
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
    sudo "$pkg_manager" install "$dnf_opts" -y

sudo "$pkg_manager" autoremove -y

echo "Permitting writes to /usr/local/bin/ ..."
sudo chown "root:${admin_group}" /usr/local/bin
sudo chmod 775 /usr/local/bin
