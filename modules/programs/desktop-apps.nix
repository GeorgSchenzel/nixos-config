{ den, ... }:

{
  den.aspects.desktop-apps = {
    # ship the terminfo of common terminals (xterm-ghostty & co) system-wide;
    # without it zsh line editing breaks in terminals whose $TERM has no
    # terminfo entry (cursor overwrites text, broken completion)
    nixos = {
      environment.enableAllTerminfo = true;
    };

    provides.to-users.homeManager = { pkgs, lib, ... }: {
      home.packages = with pkgs; [
        firefox
        thunderbird
        vscode
        obsidian
        jetbrains.pycharm
        jetbrains.idea
        qbittorrent
        signal-desktop
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        nautilus
        # wayland-native image viewer built for sway; closes on Esc
        swayimg
        vlc
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        iina
      ];

      # swayimg as the default image viewer (vlc for media). Without explicit
      # defaults, xdg falls back to satty (the screenshot annotator) for
      # png/jpeg — it also registers those mimes — and gif/svg/webp have no
      # handler at all.
      xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        defaultApplications =
          let
            swayimg = [ "swayimg.desktop" ];
            vlc = [ "vlc.desktop" ];
          in {
            "image/png" = swayimg;
            "image/jpeg" = swayimg;
            "image/gif" = swayimg;
            "image/webp" = swayimg;
            "image/svg+xml" = swayimg;
            "image/bmp" = swayimg;
            "image/tiff" = swayimg;
            "image/avif" = swayimg;
            "image/heif" = swayimg;
            "image/heic" = swayimg;
            "image/jxl" = swayimg;
            "video/mp4" = vlc;
            "video/webm" = vlc;
            "video/x-matroska" = vlc;
            "video/x-msvideo" = vlc;
            "video/quicktime" = vlc;
            "audio/mpeg" = vlc;
            "audio/flac" = vlc;
            "audio/ogg" = vlc;
            "audio/x-wav" = vlc;
          };
      };

      # swayimg: navigate images with vim motions and arrow keys
      # (Left/Right replace the default pan; Up/Down still pan when zoomed,
      # PgUp/PgDown keep their defaults)
      xdg.configFile."swayimg/init.lua" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        text = ''
          local next_image = function() swayimg.viewer.open("next") end
          local prev_image = function() swayimg.viewer.open("prev") end

          for _, key in ipairs({ "Right", "l", "j" }) do
            swayimg.viewer.on_key(key, next_image)
          end
          for _, key in ipairs({ "Left", "h", "k" }) do
            swayimg.viewer.on_key(key, prev_image)
          end

          -- vim motions for thumbnail selection in gallery mode
          swayimg.gallery.on_key("h", function() swayimg.gallery.select("left") end)
          swayimg.gallery.on_key("l", function() swayimg.gallery.select("right") end)
          swayimg.gallery.on_key("j", function() swayimg.gallery.select("down") end)
          swayimg.gallery.on_key("k", function() swayimg.gallery.select("up") end)
        '';
      };

      # runtime tools (claude-code, nautilus "open with") recreate
      # mimeapps.list as a plain file; force lets activation reclaim it
      xdg.configFile."mimeapps.list".force =
        pkgs.stdenv.hostPlatform.isLinux;

      programs.alacritty.enable = true;
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        settings = {
          # selecting text copies straight to CLIPBOARD (Ctrl+Shift+V / GUI
          # Ctrl+V), not just PRIMARY (middle-click); keeps the two clipboard
          # selections from diverging. `true` would fill both instead.
          copy-on-select = "clipboard";
        };
      };
    };

    persist-home = {
      directories = [
        ".mozilla/firefox"
        ".thunderbird"
        ".config/Code"
        ".config/obsidian"
      ];
    };

    darwin = {
      homebrew = {
        enable = true;
        casks = [
          "google-chrome"
        ];
      };
    };
  };
}
