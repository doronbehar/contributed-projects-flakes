{
  description = "Signal-Desktop development flake";

  inputs = {
    nixpkgs.url = "path:/home/doron/repos/nixpkgs";
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
        electron = pkgs.electron_44;

        # TODO: this duplicates electronLibPath from
        # nixpkgs' pkgs/development/tools/electron/binary/generic.nix, which
        # isn't currently exposed as a passthru attribute. Expose it there
        # upstream and reference it here instead of copying the list.
        nativeAddonLibs = [
          pkgs.alsa-lib
          pkgs.at-spi2-atk
          pkgs.cairo
          pkgs.cups
          pkgs.dbus
          pkgs.expat
          pkgs.gdk-pixbuf
          pkgs.glib
          pkgs.gtk3
          pkgs.gtk4
          pkgs.nss
          pkgs.nspr
          pkgs.libx11
          pkgs.libxcb
          pkgs.libxcomposite
          pkgs.libxdamage
          pkgs.libxext
          pkgs.libxfixes
          pkgs.libxrandr
          pkgs.libxkbfile
          pkgs.pango
          pkgs.pciutils
          pkgs.stdenv.cc.cc
          pkgs.systemd
          pkgs.libnotify
          pkgs.pipewire
          pkgs.libsecret
          pkgs.libpulseaudio
          pkgs.speechd-minimal
          pkgs.libdrm
          pkgs.libgbm
          pkgs.libxkbcommon
          pkgs.libxshmfence
          pkgs.libGL
          pkgs.vulkan-loader
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          # auto-patchelf is invoked directly (rather than via
          # autoPatchelfHook) since `nix develop --command` does not source
          # nativeBuildInputs' setup hooks, only runs shellHook.
          packages = [
            pkgs.nodejs_24
            pkgs.pnpm_11
            pkgs.python3
            pkgs.gcc
            pkgs.gnumake
            pkgs.pkg-config
            pkgs.jq
            pkgs.auto-patchelf
          ];

          # Use nixpkgs' own patched Electron binary instead of letting the
          # `electron` npm package download (and fail to run on NixOS) its
          # own copy of the upstream binary.
          ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
          ELECTRON_OVERRIDE_DIST_PATH = "${electron.dist}";
          ELECTRON_RUN_AS_NODE_DIST_PATH = "${electron.dist}";
          npm_config_nodedir = "${electron.headers}";

          # Without this, Electron's setuid-sandbox detection takes an
          # unsandboxed path that SIGILLs on startup. nixpkgs' own electron
          # wrapper (wrapper.nix) sets this same variable.
          CHROME_DEVEL_SANDBOX = "${electron.dist}/chrome-sandbox";

          shellHook = ''
            # ringrtc (and other native addons) are prebuilt against the
            # usual FHS runtime libraries; point their RPATH at nixpkgs'
            # equivalents, same as nixpkgs' own autoPatchelfHook would.
            autoPatchNodeModules() {
              auto-patchelf --ignore-missing '*' --paths node_modules --libs \
                ${pkgs.lib.concatMapStringsSep " " (p: "${pkgs.lib.getLib p}/lib") nativeAddonLibs}
            }
          '';
        };
      }
    );
}
