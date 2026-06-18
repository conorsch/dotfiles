#!/bin/bash
# Provision this host as a graphical workstation -- but only when it is one.
#
# On servers (and any host `is-workstation` rejects) this is a no-op, so the
# same `chezmoi update` is safe to run everywhere: servers skip the workstation
# logic, while workstations run `install-workstation` to (re)assert their setup.
#
# As a run_onchange_ script, chezmoi re-runs this only when its body changes.
# Bump the version comment below to force a re-provision on the next apply.
set -euo pipefail

# Provisioning revision -- bump to force a re-run on the next `chezmoi apply`.
# workstation-provision: 1

# These provisioning scripts reference one another by bare name, and chezmoi may
# invoke us with a minimal PATH, so make the dotfiles bin dirs discoverable.
export PATH="${HOME:?}/bin:${HOME:?}/.local/bin:${PATH}"

# Single source of truth for "is this a workstation?". Servers exit here.
if ! is-workstation ; then
    >&2 echo "Skipping workstation provisioning: not a workstation"
    exit 0
fi

install-workstation
