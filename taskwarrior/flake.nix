{
  description = "Taskwarrior development flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.pkg-config
            pkgs.rustc
            pkgs.cargo
            pkgs.installShellFiles
          ];
          # For emulating what's done in nixpkgs' cargoSetupHook
          LIBSQLITE3_SYS_USE_PKG_CONFIG = 1;
          buildInputs = [
            pkgs.corrosion
            pkgs.libuuid
            pkgs.sqlite
          ];
          # For the test suite, see
          # doc/devel/contrib/development.md#run-the-test-suite .
          nativeCheckInputs = [
            pkgs.python3
          ];
        };
      }
    );
}
