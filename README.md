dotfiles
========

This repo is a [homeshick] castle, for sychronizing dotfiles across multiple computers.

Requirements
------------

 - git

Installation
------------

```
#!/bin/bash
# Bootstrap script to deploy dotfiles on new machine.
homeshick_dir="$HOME/.homesick/repos/homeshick"
git clone https://github.com/andsens/homeshick "$homeshick_dir"
source "$homeshick_dir/homeshick.sh"

homeshick clone https://github.com/ronocdh/dotfiles
homeshick clone https://github.com/nojhan/liquidprompt
homeshick symlink dotfiles
```

That's it.

[homeshick]:https://github.com/andsens/homeshick

