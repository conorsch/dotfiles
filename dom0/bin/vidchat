#!/bin/bash
# Utility script for Qubes OS, to prepare vidchat VMs.
# Handles attaching web & mic, also raises scheduling priority
# to ensure that the vidchat VM stays snappy (reduces jitter).
set -eu -o pipefail

# Default to vidchat, but support overriding
default_vm="${VIDCHAT_VM=vidchat}"
target_vm="${1:-$default_vm}"

# Weight, between 1 and 65535, for CPU scheduling.
# The higher the value, the less "nice" the vidchat VM
# is when competing with other VMs for compute.
cpu_weight="50000"

echo "Configuring attachments for '$target_vm'..."
# Look up USB device info for camera and microphone
camera_id="$(qvm-usb ls | grep -i camera | perl -lanE 'say $F[0]' | tail -n1)"
mic_id="$(qvm-device mic ls | grep -i microphone | perl -lanE 'say $F[0]' | tail -n1)"

# Detach all USB devices from vidchat VMs, prior to correcting settings.
# List out any additional VMs that may have camera & microphone attachments,
# so they're disconnected from those VMs prior to being reconnected to the target.
for vm in "$default_vm" "$target_vm" ; do
	echo "Detaching vidchat devices from $vm ..."
	qvm-usb detach "$vm" &
	qvm-device mic detach "$vm" &
done
wait

if ! qvm-check --quiet --running "$target_vm" > /dev/null 2>&1 ; then
	printf 'Starting %s...' "$target_vm"
	qvm-start --skip-if-running "$target_vm"
	# Wait for pulseaudio to start
	sleep 15
	printf ' OK\n'
fi

printf "Attaching vidchat devices..."
qvm-usb attach "$target_vm" "$camera_id" &
qvm-device mic attach "$target_vm" "$mic_id" &
wait
printf ' OK\n'

echo "Setting CPU weight to $cpu_weight"
# via https://github.com/QubesOS/qubes-issues/issues/6190
xl sched-credit -d "$target_vm" -w "$cpu_weight"
