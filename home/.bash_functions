#!/bin/bash
git() {
   # Credit: http://unix.stackexchange.com/a/97958/16485
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/bin/git "$@" 2>&1 | tee $tmp
     repo_name=$(perl -nE $'m/Cloning into \'([\w_-]+)\'.{3}$/ and print $1;' $tmp)
     rm $tmp
     if [[ -n "$repo_name" ]]; then
         printf "changing to directory %s\n" "$repo_name"
         cd "$repo_name"
     fi
   else
     /usr/bin/git "$@"
   fi
}

git-review() {
    local target_branch
    target_branch="${1:-master}"
    git log --patch --reverse "${target_branch}..HEAD"
}

gmru() {
    # List all recently used branches within a git repo.
    # Mnemonic: "git most recently used"
    git for-each-ref --count="${1:-10}" \
        --sort=-committerdate refs/heads/ \
        --format='%(committerdate:relative) %09 %(objectname:short) %09 %(refname:short) %09 %(authorname)'
}

# List names of all contributors to a git repo
git-contributors() {
    git ls-tree -r -z --name-only HEAD -- $1 \
        | xargs -0 -n1 git blame --line-porcelain HEAD \
        | grep  "^author " \
        | sort | uniq -c | sort -nr
}

# Purges all docker containers
dockerpocalypse() {
    # Take off and nuke the entire site from orbit.
    # It's the only way to be sure.
    echo "Stopping all containers..."
    docker container ls --all --quiet \
        | xargs --no-run-if-empty docker container stop
    echo "Removing all containers..."
    docker container prune --force
    echo "Removing system prune..."
    docker system prune --force
}

# Open all files by extension
editall() {
    local file_ext
    file_ext="$1"
    shift
    find . -type f -iname '*.'"$file_ext" \
        -and -not -iname '__init__*' \
        -exec vim -p {} +
}

# Updates all system packages
getem() {
    if lsb_release -sc > /dev/null 2>&1 ; then
        sudo apt update && \
            sudo apt dist-upgrade -y --auto-remove --purge
    else
        sudo dnf upgrade -y
    fi
}
slg() {
    tail -f -n 25 /var/log/syslog
}

# Lists newest files by timestamp
newestfiles() {
    local num_files
    num_files="${1:-10}"
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 \
        | xargs -0 ls -lsh --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 7 | tail -n "$num_files"

}

# Abbreviated find command. Assumes cwd as target,
# and ignores version control files.
f() { 
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}

strlength() {
    echo "$@" | awk '{ print length }'
}

mkvenv() {
    mkvirtualenv -a $PWD "$(basename "$PWD")" -p "$(which python3)"
}
