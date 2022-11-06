#!/bin/bash
# Install rust binaries for workstation environment
# Currently using 'run_once' because compiling
# takes a long time. Might switch to on-change, though.
set -euo pipefail


source ~/.cargo/env
cargo install \
    bottom \
    tokei \
    cargo-watch
