# dev env settings for SecureDrop Workstation
export SECUREDROP_DEV_VM="sd-dev"
export SECUREDROP_DEV_DIR="/home/user/src/fpf/securedrop-workstation"


alias sdw-shutdown="qvm-ls --tags sd-workstation --raw-list --running | xargs -r qvm-shutdown --wait"
alias sdw-reboot="qvm-ls --tags sd-workstation --raw-list --running | xargs -r qvm-reboot --wait"
