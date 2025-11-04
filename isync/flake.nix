{
  description = "Maildir sync";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          inherit (pkgs.isync)
            buildInputs
            checkInputs
          ;
          nativeBuildInputs = pkgs.isync.nativeBuildInputs ++ [
            pkgs.autoreconfHook
            pkgs.perlPackages.DateTimeFormatDateParse
            pkgs.bear
          ];
        };
      }
    );
}
