#!/bin/bash
# Download custom fonts for UTF-8 emoji display in terminals.
# See relevant docs at:
#
#   * https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-5-ad-hoc-curl-download
#   * https://starship.rs/presets/nerd-font
set -euo pipefail

# See recent releases at https://github.com/ryanoasis/nerd-fonts/releases
nerd_fonts_release="v3.2.1"
nerd_font_archive_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_fonts_release}/DejaVuSansMono.zip"

printf "Setting up nerd fonts... "
# User-specific font dir.
font_dir="${HOME}/.local/share/fonts"
nerd_font_archive_filepath="${font_dir}/$(basename "$nerd_font_archive_url")"
# Download and clobber, since version could have changed.
mkdir -p "$font_dir"
curl -q -sSfL -o "$nerd_font_archive_filepath" "$nerd_font_archive_url"
unzip -o -q -d "$font_dir" "$nerd_font_archive_filepath"

# Under what circumstances is it reasonable to assume `fc-cache` is present?
if hash fc-cache > /dev/null 2>&1; then
    fc-cache --really-force
fi
printf 'OK\n'
