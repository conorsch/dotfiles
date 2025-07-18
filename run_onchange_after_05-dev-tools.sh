#!/bin/bash
# Install common dev utils.
set -eo pipefail


# Install rustup for cargo and rustc.
if ! hash cargo > /dev/null 2>&1 ; then
  # Bootstrap Rust environment, via https://rustup.rs/
  if [[ ! -e ~/.cargo ]] ; then
      echo "Getting rust..."
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

  echo "Installing rust toolchains..."
  # shellcheck source=/dev/null
  source ~/.cargo/env
  rustup component add rust-analyzer
  rustup toolchain add nightly
  rustup target add wasm32-unknown-unknown x86_64-unknown-linux-musl
  rustup update
fi

echo "Installing llm tooling"
# opencode, via https://opencode.ai/docs/
if ! hash opencode > /dev/null 2>&1 ; then
  curl -fsSL https://opencode.ai/install | bash
fi
