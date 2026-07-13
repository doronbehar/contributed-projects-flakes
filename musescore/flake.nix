{
  description = "Musescore development flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          inherit (pkgs.musescore)
            buildInputs
            checkInputs
          ;
          nativeBuildInputs = pkgs.musescore.nativeBuildInputs ++ [
          ];
          inherit (pkgs.musescore) cmakeFlags;
          # NOTE that on ZSH, instead of:
          #
          #    cmake $cmakeFlags ..
          #
          # you need to run:
          #
          #    cmake ${=cmakeFlags} ...
          #
          shellHook = ''
            cmakeFlags="$cmakeFlags -DCMAKE_INSTALL_PREFIX=$PWD/nix-install-prefix"
          '';
        };
      }
    );
}
