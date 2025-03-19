#!/bin/bash
# Install developer tooling, but only those tools appropriate
# for an interactive graphical workstation. There are a few categories
# of workstation, which must be handled slightly differently,
# in terms of config:
#
#   * physical laptop
#   * graphical workstations, via ssh
#   * qubes vms
#   * hardware servers (should be ignored)
#
#  There's logic to figure out which type of workstation
#  we're targeting, then do the needful. This script references
#  other scripts that are expected to be on PATH:
#
#  * fedora-install-flatpaks
#  * fedora-install-rpm-fusion
#  * i3-setup
set -ueo pipefail

# Install the zellij terminal emulator, via custom RPM repo.
function install_zellij() {
    sudo dnf copr enable -y varlad/zellij
    sudo dnf install -y zellij
}

# Edit user configurations for Alacritty terminal emulator.
function configure_alacritty() {
    >&2 echo "Setting up alacritty..."
    alacritty_theme_dir="${HOME:?}/.config/alacritty/themes"
    if [[ ! -d "$alacritty_theme_dir" ]] ; then
        mkdir -p "$alacritty_theme_dir"
        git clone https://github.com/alacritty/alacritty-theme "$alacritty_theme_dir"
    fi

    # The alacritty package was already installed via the default rpm repos.
    # Now we symlink it as `x-terminal-emulator` so that `i3-sensible-terminal`
    # picks it up. This seems to work better than setting `TERM=alacritty`.
    if [[ -e /usr/bin/alacritty ]] ; then
        ln -s "/usr/bin/alacritty" -f "/usr/local/bin/x-terminal-emulator"
    fi
  }

# Expect a bare metal Fedora Workstation install, with ability to customize
# RPM repos and such.
function configure_hardware_workstation() {
    # These are helper scripts also installed by chezmoi/dotfiles.
    fedora-install-flatpaks
    fedora-install-rpm-fusion
    install_zellij
    i3-setup
    install-nix
    configure_alacritty
}

# Handle config specifically for Qubes VMs. Supports both AppVM and TemplateVM types.
function configure_qubes() {
    # Check if we're a Qubes VM.
    if ! hash qubesdb-read >/dev/null 2>&1 ; then
        return 1
    fi

    # This value will likely be `AppVM` or `TemplateVM`.
    qubes_vm_type="$(qubesdb-read /qubes-vm-type)"

    if [[ "$qubes_vm_type" = "AppVM" ]] ; then
        # Don't install heavy flatpaks always, best on hardware only.
        # fedora-install-flatpaks
        configure_alacritty
    elif [[ "$qubes_vm_type" = "StandaloneVM" ]] ; then
        # Treat a standalone VM as a normal workstation.
        configure_hardware_workstation
    else
        >&2 echo "ERROR: unknown Qubes VM type '$qubes_vm_type'"
        return 1
    fi
}

# Run laptop-specific configs, for battery monitoring.
function configure_laptop() {
    # Files have already been copied, so we can assume the battery-monitor
    # scripts and user-level systemd services are in place.
    systemctl --user daemon-reload
    systemctl --user enable --now battery-monitor battery-monitor.timer
    # Also restart, in case the script itself changed.
    systemctl --user restart battery-monitor battery-monitor.timer
}

# Primary script entrypoint. Basically a big switch statement
# to match on workstation type, and do the needful.
main() {
    hostnamectl_json="$(hostnamectl status --json pretty)"
    chassis="$(jq -r .Chassis <<< "$hostnamectl_json")"
    kernel_release="$(jq -r .KernelRelease <<< "$hostnamectl_json")"
    # Hardcode primary workstation name, which often hosts ssh sessions.
    # DISPLAY won't be set, but still consider it a workstation.
    if [[ "$(hostname)" = "Antigonus" ]] ; then
        configure_hardware_workstation
    # All laptops are workstations.
    elif [[ "$chassis" = "laptop" ]] ; then
        configure_hardware_workstation
        configure_laptop
    # Desktops, but only if run within a graphical environment.
    # Skips hardware servers.
    elif [[ "$chassis" = "desktop" ]] && [[ -n "${DISPLAY:-}" ]] ; then
        configure_hardware_workstation
    # If we're in a VM running a Qubes kernel, consider that a workstation, too.
    elif [[ "$chassis" = "vm" ]] && [[ "$kernel_release"  =~ ^.*qubes.*$ ]] ; then
        >&2 echo "Detected Qubes VM"
        configure_qubes
    else
        >&2 echo "Not a workstation, skipping workstation configs"
    fi
}

main
exit 0
