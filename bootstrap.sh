#!/bin/bash
# Bootstrap script to deploy dotfiles on new machine.
set -e
set -u
set -o pipefail

github_username="${GITHUB_USERNAME:-conorsch}"
git_name="${GIT_NAME:-Conor Schaefer}"
git_email="${GIT_EMAIL:-conor@ruin.dev}"
homeshick_dir="$HOME/.homesick/repos/homeshick"

printf 'Updating homeshick...'
if [[ ! -d "$homeshick_dir" ]]; then
    mkdir -p "$(dirname "$homeshick_dir")"
    git clone https://github.com/andsens/homeshick "$homeshick_dir"
fi
git -C "$homeshick_dir" reset --hard --quiet
git -C "$homeshick_dir" checkout --quiet master
git -C "$homeshick_dir" pull --quiet origin master

source "$homeshick_dir/homeshick.sh"

function fetch_dotfiles_repo() {
    url="$1"
    shift
    local repo_name
    repo_name="$(basename "$url")"
    repo_path="$(dirname "$homeshick_dir")/${repo_name}"
    if [[ ! -d $repo_path ]]; then
        # Assume the current dir, where we cloned from,
        # is what we want as the canonical dotfiles repo
        if [[ $repo_name = "dotfiles" ]]; then
            # We can't be sure we'll have rsync
            cp -r "${PWD}"/ "${repo_path}"/
            if [[ ! $PWD =~ ^/tmp/|/dev/shm/ ]]; then
                echo "Current dotfiles repo not in temporary directory."
                echo "Dotfiles stored in $repo_path, delete $PWD"
            fi
        else
            homeshick clone "$url"
        fi
    fi
}

# homeshick config
fetch_dotfiles_repo "https://github.com/${github_username}/dotfiles" &
wait
printf ' OK\n'
homeshick symlink --force dotfiles

# vim config
printf "Syncing vim plugins... "
# curl -s -o home/.vim/autoload/plug.vim \
#    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall > /dev/null 2>&1
printf 'OK\n'

# git config
printf "Configuring git... "
git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global pull.rebase 'true'
# Perform integrity checks by default; see:
# https://groups.google.com/forum/#!topic/binary-transparency/f-BI4o
git config --global transfer.fsckobjects 'true'
git config --global fetch.fsckobjects 'true'
git config --global receive.fsckobjects 'true'
git config --global status.submodulesummary 'true'
git config --global diff.submodule 'log'
git config --global init.defaultBranch main
printf 'OK\n'

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
fi
