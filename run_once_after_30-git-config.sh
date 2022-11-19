#!/bin/bash
set -euo pipefail

git_name="${GIT_NAME:-Conor Schaefer}"
git_email="${GIT_EMAIL:-conor@ruin.dev}"

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
git config --global core.excludesFile "$HOME/.gitignore"
git config --global advice.addEmptyPathspec false

printf 'OK\n'
