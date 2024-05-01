#!/bin/bash
# Meta-level config of chezmoi, by chezmoi. Necessary because wisely
# rather wisely forbids writing to chezmoi config files via chezmoi.
# But I will not be stopped.
set -eo pipefail


mkdir -p "$HOME/.config/chezmoi"
chezmoi_config_filepath="$HOME/.config/chezmoi/chezmoi.toml"
# Could be respectful of existing configs. No, I don't think I will.
# if [[ -e "$chezmoi_config_filepath" ]] ; then
#    exit 0
# fi
cat <<EOF > "$chezmoi_config_filepath"
[diff]
    exclude = ["scripts"]
EOF
