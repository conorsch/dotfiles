lint:
    # shellcheck lint
    fd -t f '(^executable_|bash|\.sh$)' -x file --mime-type \
        | perl -F': ' -lanE '$F[-1] =~ m#text/x-shellscript$# and say $F[0]' \
        | xargs -r shellcheck
