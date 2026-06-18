# shellcheck lint
lint:
    (fd -t f -X file --mime-type \
        | perl -F': ' -lanE '$F[-1] =~ m#text/x-shellscript$# and say $F[0]' && \
        rg '^# shellcheck \w+=\w+' -l ) \
        | sort -u \
        | xargs -r shellcheck -x
    # VLC isn't supported on macOS, so don't check all systems
    # nix flake check --all-systems
    nix flake check

alias check := lint

# apply workstation configs; `chezmoi apply` runs run_onchange_after_45_workstation,
# which provisions via install-workstation (a no-op on non-workstations).
workstation:
  chezmoi apply
  bash bin/executable_install-workstation

# build the nix env to validate successful integration
build:
  nix build

# install the apt/dnf packages
packages:
  bash bin/executable_install-workstation-packages

alias pkgs := packages
