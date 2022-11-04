# dotfiles

This repo is a [chezmoi] dotfiles repo, for sychronizing dotfiles across multiple computers.

## Requirements

 - git
 - curl

## Installation

```
./bootstrap.sh
```

That's it.

## Environment variables

Override these to customize git identity:

```
GIT_EMAIL
GIT_NAME
```

Additional env vars can be set in `~/.bash_env_extra`,
which is NOT version controlled.

[chezmoi]:https://www.chezmoi.io
