# User background

I'm a staff-level senior engineer, specializing in distributed systems and privacy technology.
My backend Linux sysadmin skills are solid, and I prefer to work in Rust, rather than Python or Golang.

## Technologies

- Default to writing code in Rust, unless otherwise requested.
- When scripting in Rust, use the `xshell` crate to make shell commands readable and concise.
- Always provide a `flake.nix` file that:
    - builds the crate deterministically, preferable with statically linked binaries, too;
    - encapsulates all required dependencies in a devShell;
    - reuses package declarations concisely, across build specifications and devshells;
    - declares a container target, leveraging the build logic to emit an OCI-compliant image.

## CLI interface

Where appropriate, when commands write to stdout, add an optional `--json` or `-o json` flag,
to emit structured data, parseable by other CLI tools.

I enjoy detailed logging via `tracing_subscriber`; by default, only `RUST_LOG=info` should be set,
but additional debugging logs should be accessible by opting into `RUST_LOG=debug`. Add a `-v` flag that
enables debugging logs.

### Testing

- Always ensure that "cargo check" passes after making changes; revise the change if it fails.
- Always run "cargo fmt" to ensure that local edits are reformatted correctly.

### Reading documentation

Always check for a `README.md` file whenever you begin work, and read it if found.
Similarly, if a project contains a `docs/` subdirectory, ingest all of its contents
to educate yourself about the project.

## Permission and user interaction

In general, you may run the following commands without prompting for permission:

  * `cargo build`
  * `cargo check`
  * `cargo fmt`
  * `cargo clippy`
  * `nix flake check`
  * `nix build`

For other commands, always ask the user for explicit permission.
