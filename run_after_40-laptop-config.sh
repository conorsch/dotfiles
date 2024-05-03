#!/bin/bash
# Apply laptop-specific configuration for workstations.
set -euo pipefail


if [[ "$(hostnamectl status --json pretty | jq -r .Chassis)" != "laptop" ]]; then
    >&2 echo "Not a laptop, skipping laptop configs..."
    exit 0
fi

>&2 echo "Laptop detected, applying configs..."

# Files have already been copied, so we can assume the battery-monitor
# scripts and user-level systemd services are in place.
systemctl --user daemon-reload
systemctl --user enable --now battery-monitor battery-monitor.timer
# Also restart, in case the script itself changed.
systemctl --user restart battery-monitor battery-monitor.timer
