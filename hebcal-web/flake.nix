{
  description = "Hebcal web interface development flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, }: {
    devShell.x86_64-linux = with (import nixpkgs {system = "x86_64-linux";}); mkShell {
      nativeBuildInputs = [
        nodePackages_latest.node-gyp
        nodePackages_latest.nodejs
        sqlite
        protobuf
        protoc-gen-js
      ];
    };
  };
}
