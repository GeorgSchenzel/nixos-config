{ den, ... }:

{
  den.aspects.logseq = {
    provides.to-users.homeManager = { pkgs, lib, ... }:
      let
        logseq-bin = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "logseq-bin";
          version = "2.0.1";

          src = pkgs.fetchurl {
            url = "https://github.com/logseq/logseq/releases/download/${finalAttrs.version}/Logseq-linux-x86_64-${finalAttrs.version}.zip";
            hash = "sha256-mBvx83QDaF74MiMZN5XSm7Bym1CSnVQ8LEvOdx4wehc=";
          };

          icon = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/logseq/logseq/${finalAttrs.version}/resources/icons/logseq.png";
            hash = "sha256-44AcBUE4qcxetVXAzqmFYgcW3fYhQhNpIT2oK5//VXo=";
          };

          sourceRoot = ".";

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            makeWrapper
            patchelf
            unzip
          ];

          dlopenLibs = with pkgs; lib.makeLibraryPath [
            libGL
            wayland
          ];

          buildInputs = with pkgs; [
            alsa-lib
            at-spi2-atk
            atk
            cairo
            cups
            dbus
            expat
            glib
            gtk3
            libGL
            libdrm
            libaio
            libsecret
            wayland
            libX11
            libxcb
            libXcomposite
            libXdamage
            libXext
            libXfixes
            libXrandr
            libxkbcommon
            libxshmfence
            mesa
            nspr
            nss
            pango
            systemd
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/logseq
            cp -r * $out/share/logseq

            install -Dm644 ${finalAttrs.icon} $out/share/icons/hicolor/512x512/apps/logseq.png

            makeWrapper $out/share/logseq/logseq $out/bin/logseq \
              --inherit-argv0 \
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"

            mkdir -p $out/share/applications
            cat > $out/share/applications/logseq.desktop <<'DESKTOP'
            [Desktop Entry]
            Type=Application
            Name=Logseq
            Exec=@out@/bin/logseq %U
            Icon=logseq
            StartupWMClass=logseq
            Comment=Privacy-first, open-source platform for knowledge management and collaboration
            MimeType=x-scheme-handler/logseq;
            Categories=Utility;
            DESKTOP
            substituteInPlace $out/share/applications/logseq.desktop --replace-fail @out@ $out

            runHook postInstall
          '';

          postPhases = [ "logseqRpathPhase" ];

          logseqRpathPhase = ''
            for elf in $out/share/logseq/logseq $out/share/logseq/*.so; do
              patchelf --add-rpath ${finalAttrs.dlopenLibs} "$elf"
            done
          '';

          meta = {
            description = "Privacy-first, open-source platform for knowledge management and collaboration (upstream binary)";
            homepage = "https://github.com/logseq/logseq";
            license = lib.licenses.agpl3Only;
            mainProgram = "logseq";
            platforms = [ "x86_64-linux" ];
            sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
          };
        });
      in
      {
        home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          logseq-bin
        ];
      };

    persist-home = {
      directories = [
        ".config/Logseq"
        ".logseq"
        "logseq"
      ];
    };
  };
}
