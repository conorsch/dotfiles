{
  description = "Dev shell for managing ruin.dev dotfiles";
  # name = "ruindev-dotfiles";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    etym.url = "github:conorsch/etym";
    etym.inputs.nixpkgs.follows = "nixpkgs";

    # workspace flake for all personal CLI tools
    ruindev-tools.url = "git+https://codeberg.org/conorsch/ruindev-tools";
    ruindev-tools.inputs.nixpkgs.follows = "nixpkgs";

    # install fnox https://fnox.jdx.dev/
    fnox.url = "git+https://codeberg.org/conorsch/fnox-flake";
    fnox.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, etym, ruindev-tools, fnox }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # No upstream nix flake for lathe, so build the Go binary from source.
        # https://github.com/devenjarvis/lathe
        lathe = pkgs.buildGoModule rec {
          pname = "lathe";
          version = "0.3.0";
          src = pkgs.fetchFromGitHub {
            owner = "devenjarvis";
            repo = "lathe";
            rev = "v${version}";
            hash = "sha256-nmiFJNHgBwEuMLGIWqepAhDATuAGs4CpzCDYE4VLwjA=";
          };
          vendorHash = "sha256-6IQ0/QvnMG87COvJx+wUpViiwDY8zEsJ/HA9RWIF1XE=";
          # Stamp the version the same way upstream's goreleaser does.
          ldflags = [
            "-s"
            "-w"
            "-X github.com/devenjarvis/lathe/internal/buildinfo.Version=${version}"
          ];
        };

        # Packages only appropriate if headful machine, with monitor and speakers.
        workstationPkgs = with pkgs; [
          wiremix
          bluetui
          aider-chat

          # general dev cruft
          gh
          nodejs_22
          ollama
          pnpm
          wasm-pack

          # devops
          ansible
          aria2
          cargo-watch
          deno
          forgejo-cli
          gifski
          go
          go-grip
          harmonia
          lathe
          hyperfine
          kubectl
          oha
          python313Packages.pytest
          python313Packages.pytest-testinfra
          python313Packages.pytest-xdist
          shellcheck
          sops
          tea
          watchexec
        ];

        subFlakes = [
          etym.packages.${system}.default
          ruindev-tools.packages.${system}.default
          fnox.packages.${system}.default
        ];

        # Defining package list outside of devshell, so it can be used in devshell & container image.
        tooling = with pkgs; [
          age
          aichat
          bashInteractive
          bat
          bottom
          btop
          byobu
          coreutils
          curl
          diceware
          direnv
          dunst
          dust
          eza
          fd
          file
          fzf
          git
          glibcLocales
          gum
          htop
          magic-wormhole-rs
          jq
          just
          neovim
          ntfy-sh
          perl
          ripgrep
          rsync
          ruff
          starship
          statix
          tokei
          toml-cli
          xz
          yamllint
          yq
          zellij
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          name = "ruin.dev dotfiles";
          # nativeBuildInputs = [ pkgs.bashInteractive ];
          # TODO: make installation of workstationPkgs conditional.
          buildInputs = tooling ++ workstationPkgs ++ subFlakes;
        };

        # Add container output
        packages.container = pkgs.dockerTools.buildImage {
          name = "ruin-dev-dotfiles";
          tag = "latest";

          # Configure container contents
          copyToRoot = tooling;

          # Optional: Configure container metadata
          config = {
            Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
            WorkingDir = "/";
            # Env = [
            #   "PATH=/bin"
            #   "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            # ];
          };
        };

        # Make a proper installable package with all tools
        packages.default = pkgs.buildEnv {
          name = "ruin-dev-tools";
          paths = tooling ++ workstationPkgs ++ subFlakes;
        };
      });
}
