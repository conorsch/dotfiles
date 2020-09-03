#!/bin/bash
# Installs common packages. Supports recent
# Debian & Fedora.
set -e
set -u
set -o pipefail

debian_version="$(grep '^NAME=Debian' /etc/os-release 2> /dev/null || echo '')"
fedora_version="$(grep '^NAME=Fedora' /etc/os-release 2> /dev/null || echo '')"
if [[ -n "$debian_version" ]]; then
    pkg_manager="apt-get"
elif [[ -n "$fedora_version" ]]; then
    pkg_manager="dnf"
else
    echo "WARNING: Unknown platform"
    pkg_manager="apt-get"
fi

time_since_last_update="$(date -d "now - $(date -r packages.txt +%s) seconds" +%s)"
# An hour's plenty
time_allowed_between_updates=3600

if (( $time_since_last_update > $time_since_last_update )); then
    echo "Updating repo lists..."
    sudo "$pkg_manager" update
    touch packages.txt
fi

# Wonderful that the packages share same name...
cat packages.txt | xargs -d '\n' \
    sudo "$pkg_manager" install -y

sudo "$pkg_manager" autoremove -y
