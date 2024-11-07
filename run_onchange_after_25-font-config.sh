#!/bin/bash
# Download custom fonts for UTF-8 emoji display in terminals.
# See relevant docs at:
#
#   * https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-5-ad-hoc-curl-download
#   * https://starship.rs/presets/nerd-font
set -euo pipefail

# See recent releases at https://github.com/ryanoasis/nerd-fonts/releases
nerd_fonts_release="v3.2.1"
nerd_font_archive_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_fonts_release}/DejaVuSansMono.tar.xz"

printf "Setting up nerd fonts... "
# User-specific font dir.
font_dir="${HOME}/.local/share/fonts"
nerd_font_archive_filepath="${font_dir}/$(basename "$nerd_font_archive_url")"
# Download and clobber, since version could have changed.
mkdir -p "$font_dir"
curl -q -sSfL -o "$nerd_font_archive_filepath" "$nerd_font_archive_url"
# Use of `tar` will automatically understand `.tar.xz` archives,
# as long as xz-utils is installed.
tar -C "$font_dir" -xf "$nerd_font_archive_filepath"
# Clean up the downloaded tarball post-extraction
rm -f "$nerd_font_archive_filepath"
rm -f "${font_dir:?}"/*.zip
rm -f "${font_dir:?}"/*.tar.xz

# Under what circumstances is it reasonable to assume `fc-cache` is present?
if hash fc-cache > /dev/null 2>&1; then
    fc-cache --really-force
fi
printf 'OK\n'
