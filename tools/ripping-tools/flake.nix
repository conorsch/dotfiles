{
  description = "Utilities for ripping CDs to FLAC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgsStatic = pkgs.pkgsStatic;
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        packageName = "ripping-tools";
      in
      {
        packages.default =
          let
            unwrapped = pkgsStatic.rustPlatform.buildRustPackage {
              pname = packageName + "-unwrapped";
              version = cargoToml.package.version;

              src = ./.;

              cargoLock = {
                lockFile = ./Cargo.lock;
              };
            };

            runtimeDeps = with pkgs; [
              fd
              rsync
              vlc
              coreutils
              findutils
            ];
          in
          pkgs.symlinkJoin {
            name = packageName;
            paths = [ unwrapped ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/${packageName} \
                --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
            '';
          };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bashInteractive
            cargo
            curl
            fd
            just
            rsync
            rustc
          ];
        };
      }
    );
}
