dotfiles
========

This repo is a [homesick] castle, for sychronizing dotfiles across multiple computers.

Requirements
------------

 - rubygems
 - [homesick]

Installation
------------

After installing both `ruby` and `rubygems`, run:

```
gem install --user-install homesick
alias homesick="$(ruby -rubygems -e 'puts Gem.user_dir')/bin/homesick"
homesick clone https://github.com/ronocdh/dotfiles
homesick symlink --force dotfiles
```

That's it.

[homesick]:https://github.com/technicalpickles/homesick

