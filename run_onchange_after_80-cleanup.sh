#!/bin/bash
# Perform ad-hoc cleanup of crufty legacy configs.
set -eo pipefail


# Migrated the gdm logic to lightdm, via `i3-setup` script.
rm -vf ~/bin/fedora-login-wallpaper
