{
  description = "Musescore development flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";

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
        qtVersion = "6";
        qtDrvs = [
          "qt5compat"
          "qtbase"
          "qtdeclarative"
          "qtnetworkauth"
          "qtscxml"
          "qtsvg"
        ];
        qtGetVarMap = (
          qtVar:
          map (
            attr:
            pkgs.lib.pipe attr [
              (a: pkgs."qt${qtVersion}".${a})
              pkgs.lib.getBin
              (binPkg: "${binPkg}/${pkgs."qt${qtVersion}".qtbase.${qtVar}}")
            ]
          )
        );
      in
      {
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
          QT_PLUGIN_PATH = pkgs.lib.pipe qtDrvs [
            (qtGetVarMap "qtPluginPrefix")
            (pkgs.lib.concatStringsSep ":")
          ];
          QML2_IMPORT_PATH = pkgs.lib.pipe qtDrvs [
            (qtGetVarMap "qtQmlPrefix")
            (pkgs.lib.concatStringsSep ":")
          ];
          # The following might be required on some platforms
          #QT_QPA_PLATFORM="xcb";
          XDG_DATA_DIRS = pkgs.lib.concatStringsSep ":" [
            # So we'll be able to save figures from the plot dialog
            "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
            "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
            # So pdf mime types and perhaps others could be detected by 'gio open'
            # / xdg-open. TODO: Is this the best way to overcome this issue -
            # manually every time we generate a devShell?
            "${pkgs.shared-mime-info}/share"
            "${pkgs.hicolor-icon-theme}/share"
          ];
          GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/${pkgs.gdk-pixbuf.moduleDir}.cache";
        };
      }
    );
}
