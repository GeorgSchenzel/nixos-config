{ den, ... }:
{
  den.aspects.fmod = {
    provides.to-users.homeManager = { pkgs, lib, ... }:
      let
        # FMOD Studio is not in nixpkgs and its downloads are login-gated
        # (unfree, no redistribution), so the AppImage never enters the
        # store. This runner launches it from a persisted user directory;
        # updating it is just replacing the file in ~/Applications — no
        # rebuild involved.
        #
        # appimage-run's default FHS env (steam chroot heritage) is missing
        # several libs FMOD's bundled Qt6/WebEngine build needs; if a launch
        # fails with a missing library, append it here.
        fmodstudioRunner = pkgs.appimage-run.override {
          extraPkgs = p: with p; [
            libxshmfence
            libxkbcommon
            libxkbfile
            libxcb-cursor
            libXau
            wayland
            alsa-lib
            libpulseaudio
            libgbm
          ];
        };

        fmodstudio = pkgs.writeShellScriptBin "fmodstudio" ''
          img="$(find "$HOME/Applications" -maxdepth 1 -iname '*fmodstudio*.appimage' 2>/dev/null | sort -V | tail -n1 || true)"
          if [ -z "$img" ]; then
            echo "fmodstudio: no *fmodstudio*.AppImage in ~/Applications found." >&2
            echo "Download FMOD Studio for Linux (AppImage) from" >&2
            echo "  https://www.fmod.com/download" >&2
            echo "and place it in ~/Applications/." >&2
            exit 1
          fi
          exec ${lib.getExe fmodstudioRunner} "$img" "$@"
        '';
      in
      {
        # Guarded so the aspect is safe to include on darwin later.
        home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ fmodstudio ];

        xdg.desktopEntries.fmodstudio = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          name = "FMOD Studio";
          exec = "fmodstudio";
          terminal = false;
          categories = [ "AudioVideo" "Audio" "AudioVideoEditing" ];
        };
      };

    # The AppImage is dropped into ~/Applications by the user (login-gated
    # download, see wrapper above). FMOD Studio's Qt user data lives in
    # ~/.local/share/FMOD Studio (path verified on first launch).
    persist-home = {
      directories = [
        "Applications"
        ".local/share/FMOD Studio"
      ];
    };
  };
}
