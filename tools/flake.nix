{
  description = "ruindev-tools: personal CLI utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, rust-overlay, crane }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      rustToolchainFor = pkgs: pkgs.rust-bin.stable.latest.default.override {
        targets = [ "x86_64-unknown-linux-musl" "aarch64-unknown-linux-musl" ];
      };

      craneLibFor = pkgs: (crane.mkLib pkgs).overrideToolchain (rustToolchainFor pkgs);

      # Single workspace version, read from root Cargo.toml
      workspaceVersion =
        (builtins.fromTOML (builtins.readFile ./Cargo.toml)).workspace.package.version;

      # Shared build arguments (dynamic linking)
      commonArgs = pkgs: craneLib: {
        src = craneLib.cleanCargoSource ./.;
        pname = "ruindev-tools";
        version = workspaceVersion;
        strictDeps = true;

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          openssl
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
        ];
      };

      # Static build arguments (MUSL)
      staticArgs = pkgs: craneLib: let
        target = if pkgs.stdenv.hostPlatform.isAarch64
                 then "aarch64-unknown-linux-musl"
                 else "x86_64-unknown-linux-musl";
      in {
        src = craneLib.cleanCargoSource ./.;
        pname = "ruindev-tools";
        version = workspaceVersion;
        strictDeps = true;

        CARGO_BUILD_TARGET = target;
        CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static";

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          pkgsStatic.openssl
        ];

        OPENSSL_STATIC = "1";
        OPENSSL_LIB_DIR = "${pkgs.pkgsStatic.openssl.out}/lib";
        OPENSSL_INCLUDE_DIR = "${pkgs.pkgsStatic.openssl.dev}/include";
      };

      # Build a single crate from the workspace
      buildCrate = { pkgs, craneLib, cargoArtifacts, args, pname }:
        craneLib.buildPackage (args // {
          inherit cargoArtifacts pname;
          version = workspaceVersion;
          cargoExtraArgs = "--package ${pname}";

          meta = {
            license = pkgs.lib.licenses.agpl3Only;
            mainProgram = pname;
          };
        });

      # Wrap a binary with runtime PATH dependencies
      wrapBin = { pkgs, drv, name, runtimeDeps }:
        pkgs.symlinkJoin {
          inherit name;
          paths = [ drv ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/${name} \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
          '';
        };

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          craneLib = craneLibFor pkgs;
          args = commonArgs pkgs craneLib;
          sArgs = staticArgs pkgs craneLib;
          cargoArtifacts = craneLib.buildDepsOnly args;
          cargoArtifactsStatic = craneLib.buildDepsOnly sArgs;

          # Dynamic builds (unwrapped)
          gaming-vids-unwrapped = buildCrate {
            inherit pkgs craneLib cargoArtifacts args;
            pname = "gaming-vids";
          };

          ripping-tools-unwrapped = buildCrate {
            inherit pkgs craneLib cargoArtifacts args;
            pname = "ripping-tools";
          };

          homelab-drv = buildCrate {
            inherit pkgs craneLib cargoArtifacts args;
            pname = "homelab";
          };

          # Static builds
          homelab-static-drv = buildCrate {
            inherit pkgs craneLib;
            cargoArtifacts = cargoArtifactsStatic;
            args = sArgs;
            pname = "homelab";
          };

          # Wrapped binaries with runtime PATH deps
          gaming-vids-wrapped = wrapBin {
            inherit pkgs;
            drv = gaming-vids-unwrapped;
            name = "gaming-vids";
            runtimeDeps = with pkgs; [ fd rsync vlc coreutils findutils ];
          };

          ripping-tools-wrapped = wrapBin {
            inherit pkgs;
            drv = ripping-tools-unwrapped;
            name = "ripping-tools";
            runtimeDeps = with pkgs; [ fd rsync vlc coreutils findutils ];
          };

          # Container image for homelab
          container = pkgs.dockerTools.buildLayeredImage {
            name = "homelab";
            tag = workspaceVersion;

            contents = [
              homelab-static-drv
              pkgs.cacert
              pkgs.coreutils
              pkgs.git
              pkgs.rsync
            ];

            config = {
              Entrypoint = [ "${homelab-static-drv}/bin/homelab" ];
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
            };
          };
        in
        {
          default = pkgs.symlinkJoin {
            name = "ruindev-tools";
            paths = [ gaming-vids-wrapped ripping-tools-wrapped homelab-drv ];
          };

          gaming-vids = gaming-vids-wrapped;
          ripping-tools = ripping-tools-wrapped;
          homelab = homelab-drv;
          homelab-static = homelab-static-drv;
          inherit container;
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          rustToolchain = rustToolchainFor pkgs;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustToolchain
              rust-analyzer
              pkg-config
              openssl

              # Runtime tools
              coreutils
              curl
              fd
              findutils
              git
              just
              rsync
            ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];

            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };
        });

      overlays.default = final: prev: {
        ruindev-tools = self.packages.${final.system}.default;
        homelab = self.packages.${final.system}.homelab;
        gaming-vids = self.packages.${final.system}.gaming-vids;
        ripping-tools = self.packages.${final.system}.ripping-tools;
      };
    };
}
