{
  description = "Homelab management CLI and library";

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

      commonArgs = pkgs: craneLib: {
        src = craneLib.cleanCargoSource ./.;
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

      staticArgs = pkgs: craneLib: let
        target = if pkgs.stdenv.hostPlatform.isAarch64
                 then "aarch64-unknown-linux-musl"
                 else "x86_64-unknown-linux-musl";
      in {
        src = craneLib.cleanCargoSource ./.;
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

      homelabFor = system:
        let
          pkgs = pkgsFor system;
          craneLib = craneLibFor pkgs;
          args = commonArgs pkgs craneLib;
          cargoArtifacts = craneLib.buildDepsOnly args;
        in
        craneLib.buildPackage (args // {
          inherit cargoArtifacts;

          meta = {
            description = "Homelab management CLI and library";
            homepage = "https://github.com/conor/homelab";
            license = pkgs.lib.licenses.mit;
            mainProgram = "homelab";
          };
        });

      homelabStaticFor = system:
        let
          pkgs = pkgsFor system;
          craneLib = craneLibFor pkgs;
          args = staticArgs pkgs craneLib;
          cargoArtifacts = craneLib.buildDepsOnly args;
        in
        craneLib.buildPackage (args // {
          inherit cargoArtifacts;

          meta = {
            description = "Homelab management CLI and library (static)";
            homepage = "https://github.com/conor/homelab";
            license = pkgs.lib.licenses.mit;
            mainProgram = "homelab";
          };
        });

      containerFor = system:
        let
          pkgs = pkgsFor system;
          homelab = homelabStaticFor system;
        in
        pkgs.dockerTools.buildLayeredImage {
          name = "homelab";
          tag = "latest";

          contents = [
            homelab
            pkgs.cacert
            pkgs.coreutils
            pkgs.git
            pkgs.rsync
          ];

          config = {
            Entrypoint = [ "${homelab}/bin/homelab" ];
            Env = [
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
        };
    in
    {
      packages = forAllSystems (system: {
        default = homelabFor system;
        homelab = homelabFor system;
        homelab-static = homelabStaticFor system;
        container = containerFor system;
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
              git
              rsync
            ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];

            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };
        });

      overlays.default = final: prev: {
        homelab = self.packages.${final.system}.default;
      };
    };
}
