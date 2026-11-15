{ den, inputs, ... }:

{
  den.aspects.herdr-app = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }:
    let
      # the official release tarball (manifest: releases.herdr.dev/app/latest.json),
      # the same pattern stew uses for herdr-core. The binary links libxcb and
      # libxkbcommon directly; GPUI dlopens the graphics/font/audio stack at
      # runtime, so those join LD_LIBRARY_PATH instead of RPATH.
      version = "0.1.15";
      assets = {
        x86_64-linux = {
          cpu = "x86_64";
          hash = "sha256-+Z4eBL6CwOELL2nudAPKNDhvSA2SUR31hlr0cD52Vd0=";
        };
        aarch64-linux = {
          cpu = "aarch64";
          hash = "sha256-Dl/ZWgVkUuwx4y/mqlpHqLHUICCujzoQzaLgoQAdQSQ=";
        };
      };
      asset =
        assets.${pkgs.stdenv.hostPlatform.system}
        or (throw "herdr-app: no release build for ${pkgs.stdenv.hostPlatform.system}");

      herdr-app = pkgs.stdenv.mkDerivation {
        pname = "herdr-app";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://releases.herdr.dev/app/${version}/herdr-app-linux-${asset.cpu}.tar.gz";
          inherit (asset) hash;
        };
        sourceRoot = ".";

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
        ];
        buildInputs = with pkgs; [
          libgcc
          libxcb
          libxkbcommon
        ];

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          install -Dm 0755 herdr-app/herdr-app $out/bin/herdr-app
          install -Dm 0644 herdr-app/herdr-app.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
          install -Dm 0644 herdr-app/LICENSE herdr-app/THIRD-PARTY-NOTICES -t $out/share/doc/herdr-app/
          runHook postInstall
        '';

        postFixup = ''
          wrapProgram $out/bin/herdr-app --prefix LD_LIBRARY_PATH : ${
            lib.makeLibraryPath (with pkgs; [
              vulkan-loader
              wayland
              fontconfig
              alsa-lib
            ])
          }
        '';

        meta = {
          description = "Herdr: an app for running coding agents, built on herdr-core";
          homepage = "https://herdr.dev";
          mainProgram = "herdr-app";
          platforms = builtins.attrNames assets;
        };
      };
    in
    {
      home.packages = [ herdr-app ];

      xdg.desktopEntries.herdr-app = {
        name = "Herdr";
        comment = "Terminals and coding agents that keep running";
        exec = "herdr-app";
        icon = "${herdr-app}/share/icons/hicolor/scalable/apps/herdr-app.svg";
        terminal = false;
        categories = [ "Development" ];
      };
    };
  };
}
