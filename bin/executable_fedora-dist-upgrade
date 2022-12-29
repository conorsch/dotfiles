#!/bin/bash
# Upgrade between major versions of Fedora Workstation.
# via https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/
set -euo pipefail

# Sanity check: are we running Fedora?
if ! grep -q '^NAME="Fedora' /etc/os-release ; then
    >&2 echo "ERROR: not a Fedora installation, exiting"
    exit 1
fi

# Figure out the next target Fedora version, so I don't
# have to tweak this script every six months.
current_fedora_version="$(hostnamectl --json pretty \
    | jq -r .OperatingSystemCPEName \
    | perl -F: -lanE 'say $F[-1]')"
next_fedora_version="$((current_fedora_version + 1))"

echo "Would upgrade from F$current_fedora_version -> F$next_fedora_version"
# exit because these commands are useful mostly as a reference for now
exit 0

sudo dnf upgrade -y --refresh
# technically supposed to reboot here
sudo dnf install -y dnf-plugin-system-upgrade
sudo dnf system-upgrade download --releasever="$next_fedora_version"
sudo dnf system-upgrade reboot
