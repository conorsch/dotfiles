#!/bin/bash
set -eo pipefail

# font config (for starship emojis)
font_dir="${HOME}/.local/share/fonts"
font_path="${font_dir}/DejaVu Sans Mono Nerd Font Complete Mono.ttf"
font_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.ttf?raw=true"
if [[ ! -s "$font_path" ]]; then
    printf "Grabbing nerd fonts... "
    mkdir -p "$font_dir"
    curl -q -sSfL -o "$font_path" "$font_url"
    if hash fc-cache > /dev/null 2>&1; then
        fc-cache -f
    fi
    printf 'OK\n'
else
    echo "Fonts already configured..."
fi
