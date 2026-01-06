
# open a terminal in target vm
function t() {
    local vm
    if [[ $# -lt 1 ]]; then
	    >&2 echo "Usage: t <vm>"
	    return 1
    fi
    vm="$1"
    shift 1
    if ! qvm-check --quiet "$vm" > /dev/null 2>&1 ; then
	    >&2 echo "Error: vm does not exist: $vm"
	    return 2
    fi


    >&2 echo "Running terminal inside '$vm'..."
    qvm-run -q "$vm" "alacritty || ghostty || qubes-run-terminal" &
    # qvm-run -q "$vm" "ghostty || alacritty || qubes-run-terminal" &
    disown
    exit
    # qvm-run -q "$vm" "qubes-run-terminal"
    # qvm-run -q "$vm" "alacritty"

}

# User specific environment and startup programs
PATH="$PATH:$HOME/.local/bin:$HOME/bin"
export PATH

# `qvm-template list` is valid, but `qvm-template ls` is not?? madness!
# alias qvm-template

export TERMINAL=xfce4-terminal
# export TERMINAL=alacritty

# esc to caps lock
setxkbmap -option caps:escape
setxkbmap -option ralt:compose
setxkbmap -option compose:ralt

# hexagon development
export HEXAGON_DEV_VM="sd-dev"
export HEXAGON_DEV_DIR="/home/user/src/hexagon"


alias qvm-shutdown-templates="qvm-ls  --running --raw-data | perl -F'\|' -nE '\$F[2] eq \"TemplateVM\" and say \$F[0]' | xargs -r qvm-shutdown --wait"

