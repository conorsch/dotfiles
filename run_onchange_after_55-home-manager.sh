#!/bin/bash
# Install `home-manager` for nix installation of PATH programs.
# Only do so if `nix` is already installed.
set -ueo pipefail


# The channel of nixpkgs to use for home-manager. Must be supported by the version
# of home-manager being used! See docs for details:
# https://home-manager.dev/manual/24.11/
home_manager_nix_channel="24.11"

# Perform "standalone" installation of home-manager. See docs at:
# https://nix-community.github.io/home-manager/index.xhtml#ch-installation
function install_home_manager() {
    # Workaround for a bug where home-manager assumes files exist but they don't.
    # https://github.com/nix-community/home-manager/issues/3734
    # error msg is:
    #
    #   error: opening lock file '/nix/var/nix/profiles/per-user/conor/profile.lock': No such file or directory
    #
    # so let's make sure the solution addresses that path.
    sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/"${USER:?}"
    sudo chown -R "${USER:?}:nixbld" /nix/var/nix/{profiles,gcroots}/per-user/"${USER:?}"

    # Uses the "standalone" installation type for home-manager.
    nix-channel --add "https://github.com/nix-community/home-manager/archive/release-${home_manager_nix_channel}.tar.gz" home-manager
    nix-channel --update

    # unset prohibition of unbound variables, otherwise home-manager installer fails
    set +u
    nix-shell '<home-manager>' -A install
    home-manager switch
    set -u
}

# Check whether `nix` is installed and configured.
function is_nix_installed() {
  result=1
  if hash nix 2> /dev/null && test -d /nix ; then
    result=0
  fi
  return "$result"
}

# Primary script entrypoint. Checks whether nix is installed,
# and configures home-manager if so.
main() {
  if ! is_nix_installed ; then
    >&2 echo "DEBUG: nix is not installed, so skipping home-manager installation"
    exit 0
  fi

  install_home_manager
}

main
exit 0
