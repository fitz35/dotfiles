{
  description = "Rust dev environment with unified toolchain";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    repo.url = "https://gitlab.com/ort1e/swh-repo-mining.git";

    rust-overlay.url = "github:oxalica/rust-overlay";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:

      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        pythonPackages = pkgs.python312Packages;

        # your full toolchain (rustc, cargo, rust-src, rust-analyzer, etc.)
        fullToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        devShell = pkgs.mkShell rec {
          packages = with pkgs;[ 
            #############################################
            # Rust toolchain and bindings
            #############################################

            fullToolchain
            rustPlatform.bindgenHook

            #############################################
            # C/C++ toolchain
            # > https://github.com/Nicoshev/rapidhash
            #############################################
            llvmPackages_latest.libclang    # LLVM libs


            ###############################
            # Python
            ###############################
            pythonPackages.python
            pythonPackages.venvShellHook
            autoPatchelfHook

          ];

          #############################################
          # Python venv handling
          #############################################
          venvDir = "./.venv";

          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH

            
            pip install -r requirements-swh.txt

            autoPatchelf ./.venv
          '';

          postShellHook = ''
            unset SOURCE_DATE_EPOCH
          '';
        };
      }
    );
}
