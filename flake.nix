{
  description = "Dev shell for managing ruin.dev dotfiles";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.etym = {
    url = "github:conorsch/etym";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, etym }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };


        # Defining package list outside of devshell, so it can be used in devshell & container image.
        tooling = with pkgs; [
          age
          ansible
          bashInteractive
          coreutils
          etym.packages.${system}.default
          fd
          file
          glibcLocales
          go
          gum
          jq
          just
          kubectl
          ntfy-sh
          perl
          python313Packages.pytest
          python313Packages.pytest-testinfra
          python313Packages.pytest-xdist
          rsync
          ruff
          shellcheck
          sops
          xz
          yamllint
          yq
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "ruin.dev dotfiles";
          # nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = tooling;
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

        # Make the devShell the default package
        packages.default = self.devShells.${system}.default.inputDerivation;
      });
}
