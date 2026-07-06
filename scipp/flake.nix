{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python3;
    in
    {
      devShell = pkgs.mkShell {
        nativeBuildInputs = [
          python.pkgs.pytest
          python.pkgs.pip
          python.pkgs.mypy
          python.pkgs.ruff
        ]
        ++ python.pkgs.scipp.nativeBuildInputs
        ;
        buildInputs = [
        ]
        ++ python.pkgs.scipp.buildInputs
        ;
        propagatedBuildInputs = [
        ]
        ++ python.pkgs.scipp.propagatedBuildInputs
        ++ python.pkgs.scipp.dependencies
        ;
        # Install to this path with:
        #
        # python -m pip install \
        #   --config-settings=build-dir=build \
        #   --config-settings=editable.rebuild=true \
        #   --config-settings=editable.verbose=true \
        #   --prefix dist/nix \
        #   --no-build-isolation \
        #   --editable .
        #
        #
        # Run test(s) with (e.g):
        #
        #   env NIX_PYTHONPATH=$INSTALLDIR \
        #     python -m pytest \
        #     tests/slice_test.py
        #
        INSTALLDIR = "dist/nix/${python.sitePackages}";
      };
    }
  );
}
