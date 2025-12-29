# shellcheck lint
lint:
    (fd -t f -X file --mime-type \
        | perl -F': ' -lanE '$F[-1] =~ m#text/x-shellscript$# and say $F[0]' && \
        rg '^# shellcheck \w+=\w+' -l ) \
        | sort -u \
        | xargs -r shellcheck

# apply only workstation configs
workstation:
  bash bin/executable_install-workstation
