# User background

I'm a staff-level senior engineer, specializing in distributed systems and privacy technology.
My backend Linux sysadmin skills are solid, and I prefer to work in Rust, rather than Python or Golang.

## Technologies

Default to writing code in Rust, unless otherwise requested.
When scripting in Rust, use the `xshell` crate to make shell commands readable and concise.
Some common crates I prefer are:

  * [xshell](https://crates.io/crates/xshell) for keeping shell commands readable and concise
  * [tracing_subscriber](https://crates.io/crates/tracing-subscriber) for configurable logging
  * [clap](https://crates.io/crates/clap), specifically via the struct pattern, for CLIs

When composing a crate, always use a `src/lib.rs` file to expose library methods.
If the crate also has a CLI, then it should use `src/main.rs` that calls into `src/lib.rs`,
effectively making the crate both a library and a binary.

It's important to be explicit about build dependencies. Always provide a `flake.nix` file that
builds the crate deterministically, preferable with statically linked binaries, too.
All required dependencies should be encapsulated in a devShell.

## CLI interface

Where appropriate, when commands write to stdout, add an optional `--json` or `-o json` flag,
to emit structured data, parseable by other CLI tools.

I enjoy detailed logging via `tracing_subscriber`; by default, only `RUST_LOG=info` should be set,
but additional debugging logs should be accessible by opting into `RUST_LOG=debug`. Add a `-v` flag that
enables debugging logs. Make sure to configure `tracing_subscriber` to log to stderr, so that log
messages don't pollute stdout.

### Testing

Look for a `justfile` in the project root, as it may have useful wrappers for invoking tests.

### Reading documentation

Always check for a `README.md` file whenever you begin work, and read it if found.
Similarly, if a project contains a `docs/` subdirectory, ingest all of its contents
to educate yourself about the project.
