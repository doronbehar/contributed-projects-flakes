{
  description = "Flake for pint Python package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self
  , nixpkgs
  , flake-utils
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python3.override {
          packageOverrides = selfPython: superPython: {
            pint = superPython.pint.overridePythonAttrs (oldAttrs: {
              src = ./.;
              nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
                superPython.pkgs.git
              ];
              nativeCheckInputs = oldAttrs.nativeCheckInputs ++ [
                superPython.python.pkgs.pytest-benchmark
              ];
            });
          };
        };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = pkgs.python3.pkgs.pint.nativeBuildInputs ++ [
              pkgs.git
              pkgs.black
            ];
            nativeCheckInputs = pkgs.python3.pkgs.pint.nativeCheckInputs ++ [
              pkgs.python3.pkgs.pytest-benchmark
            ];
          };
        };
        packages = {
          pint = python.pkgs.pint;
        };
      }
    );
}
