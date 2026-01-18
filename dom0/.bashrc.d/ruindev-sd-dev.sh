# dev env settings for SecureDrop Workstation
export SECUREDROP_DEV_VM="sd-dev"
export SECUREDROP_DEV_DIR="/home/user/src/fpf/securedrop-workstation"


alias sdw-shutdown="qvm-ls --tags sd-workstation --raw-list --running | xargs -r qvm-shutdown --wait"
alias sdw-reboot="qvm-ls --tags sd-workstation --raw-list --running | xargs -r qvm-reboot --wait"

# set all SDW VMs to their fresh boot state, i.e.
# autostart=True are running, autostart=False are shutdown.
function sdw-reconcile() {
  for sdw_vm in $(qvm-ls --tags sd-workstation --raw-list ) ; do
    if [[ $(qvm-prefs $sdw_vm autostart) = "True" ]] ; then
      qvm-start $sdw_vm &
    else
      qvm-shutdown $sdw_vm &
    fi
  done
  wait
  echo "All SDWs reset to post-fresh-boot running state"
}
