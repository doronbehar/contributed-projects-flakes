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
        # Use these variables in ./src/_c_internal_utils.cpp
        LIBX11_REPLACEMENT = "${pkgs.xorg.libX11}/lib/libX11.so.6";
        LIBWAYLAND_EPLACEMENT = "${pkgs.wayland}/lib/libwayland-client.so.0";
        nativeBuildInputs = [
          python.pkgs.pytest
          python.pkgs.meson-python
          python.pkgs.pip
          python.pkgs.mypy
          python.pkgs.flake8
          pkgs.ninja
        ]
        ++ python.pkgs.matplotlib.nativeBuildInputs
        ;
        buildInputs = [
        ]
        ++ python.pkgs.matplotlib.buildInputs
        ;
        propagatedBuildInputs = [
          # To test qt backend related scripts
          python.pkgs.pyqt6
        ]
        ++ python.pkgs.matplotlib.propagatedBuildInputs
        ++ python.pkgs.matplotlib.dependencies
        ;
        QT_PLUGIN_PATH = pkgs.lib.pipe [
          pkgs.qt6.qtbase
          pkgs.qt6.qtwayland
        ] [
          (map (p: "${pkgs.lib.getBin p}/${pkgs.qt6.qtbase.qtPluginPrefix}"))
          (pkgs.lib.concatStringsSep ":")
        ];
        QT_QPA_PLATFORM="wayland";
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
        # Install to this path with (in contrast to upstream's documentation):
        #
        # python -m pip install \
        #   --config-settings=setup-args="-Dsystem-freetype=true" \
        #   --config-settings=setup-args="-Dsystem-qhull=true" \
        #   --config-settings=setup-args="-Db_lto=false" \
        #   --config-settings=builddir=build \
        #   --prefix dist/nix \
        #   --no-build-isolation \
        #   ".[dev]" 
        #
        #
        # Run test(s) with (e.g):
        #
        #   pytest \
        #     --import-mode=append \
        #     --showlocals \
        #     $INSTALLDIR/matplotlib/tests/test_ticker.py \
        #     -k 'TestLogFormatterMathtext'
        INSTALLDIR = "dist/nix/${python.sitePackages}";
      };
    }
  );
}
