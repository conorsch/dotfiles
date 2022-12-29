#!/bin/bash
set -eo pipefail

# vim config
printf "Syncing vim plugins... "
vim +PlugInstall +qall > /dev/null 2>&1
printf 'OK\n'
