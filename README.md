# dotfiles

This repo is a [chezmoi] dotfiles repo, for sychronizing dotfiles across multiple computers.

## Requirements

 - `git`
 - `bash`
 - `curl`

 Works on Fedora Workstation, Debian Stable, and Qubes OS dom0.

## Installation

```
./bootstrap.sh
```

That's it.

## dom0

For Qubes OS dotfiles, there's a `dom0/` subdir that's hardcoded: no chezmoi fanciness,
just filepaths suitable for tarballs.

[chezmoi]:https://www.chezmoi.io
