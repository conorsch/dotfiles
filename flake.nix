{
  description = "Dev shell for managing ruin.dev dotfiles";
  # name = "ruindev-dotfiles";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.etym = {
    url = "github:conorsch/etym";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };
  inputs.gaming-vids = {
    url = "path:./tools/gaming-vids";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };
  inputs.ripping-tools = {
    url = "path:./tools/ripping-tools";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, etym, gaming-vids, ripping-tools }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        # Packages only appropriate if headful machine, with monitor and speakers.
        workstationPkgs = with pkgs; [
          wiremix
          bluetui

          # media tooling
          gaming-vids.packages.${system}.default
          ripping-tools.packages.${system}.default

          # general dev cruft
          pnpm
          nodejs_22
          wasm-pack

          # devops
          ansible
          cargo-watch
          gifski
          go
          go-grip
          hyperfine
          kubectl
          oha
          python313Packages.pytest
          python313Packages.pytest-testinfra
          python313Packages.pytest-xdist
          shellcheck
          sops
          watchexec
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
          etym.packages.${system}.default
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
          buildInputs = tooling ++ workstationPkgs;
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
          paths = tooling ++ workstationPkgs;
        };
      });
}
