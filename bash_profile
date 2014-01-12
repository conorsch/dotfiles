source ~/.bashrc

if [[ -f ~/.bash_env_secure ]]; then
    source ~/.bash_env_secure
fi

eval "$(rbenv init -)"

# configure local Ruby gem support
if which ruby >/dev/null && which gem >/dev/null; then
    # I like my gems out of the way, so stuff 'em in ~/.gems:
    export GEM_HOME="$HOME/.gems"
    export GEM_PATH="$GEM_HOME/bin"
    export PATH="$PATH:$GEM_PATH"
    # assume rbenv is present if ruby is:
    export PATH="$HOME/.rbenv/bin:$PATH"
fi
