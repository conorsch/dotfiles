# shellcheck lint
lint:
    (fd -t f -X file --mime-type \
        | perl -F': ' -lanE '$F[-1] =~ m#text/x-shellscript$# and say $F[0]' && \
        rg '^# shellcheck \w+=\w+' -l ) \
        | sort -u \
        | xargs -r shellcheck
    # VLC isn't supported on macOS, so don't check all systems
    # nix flake check --all-systems
    nix flake check
    # Check for outdated local flake info
    nix flake update gaming-vids && git diff --quiet ./flake.lock

# apply only workstation configs
workstation:
  bash bin/executable_install-workstation
