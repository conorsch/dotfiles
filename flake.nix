{
  description = "Dev shell for managing ruin.dev dotfiles";
  # name = "ruindev-dotfiles";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    etym.url = "github:conorsch/etym";
    etym.inputs.nixpkgs.follows = "nixpkgs";

    # sub-flakes managed in the tools/ dir
    gaming-vids.url = "path:./tools/gaming-vids";
    gaming-vids.inputs.nixpkgs.follows = "nixpkgs";
    homelab.url = "path:./tools/homelab";
    homelab.inputs.nixpkgs.follows = "nixpkgs";
    ripping-tools.url = "path:./tools/ripping-tools";
    ripping-tools.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, etym, gaming-vids, homelab, ripping-tools }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Packages only appropriate if headful machine, with monitor and speakers.
        workstationPkgs = with pkgs; [
          wiremix
          bluetui

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

        subFlakes = [
          etym.packages.${system}.default
          gaming-vids.packages.${system}.default
          homelab.packages.${system}.default
          ripping-tools.packages.${system}.default
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
