{ ... }:

{
  flake.modules.homeManager.desktop-environment = { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
      ];

      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
      };

      wayland.windowManager.sway = {
        enable = true;
        systemd.enable = true;
        xwayland = true;

        config = rec {
          modifier = "Mod4";
          terminal = "alacritty";
          menu = "rofi -show drun";

          input = {
            "type:keyboard" = {
              xkb_layout = "de";
            };
            "type:pointer" = {
              accel_profile = "flat";
            };
            "type:touchpad" = {
              tap = "enabled";
              natural_scroll = "enabled";
              dwt = "enabled";
            };
          };

          output = {
            DP-2 = {
              mode = "3440x1440@100Hz";
              pos = "0 0";
              bg = "#1e1e2e solid_color";
            };
            HDMI-A-1 = {
              mode = "1920x1080";
              pos = "3440 0";
              transform = "90";
              bg = "#1e1e2e solid_color";
            };
          };

          gaps = {
            inner = 5;
            outer = 5;
          };

          window = {
            border = 2;
            titlebar = false;
          };

          colors = {
            focused = {
              border = "#89b4fa";
              background = "#89b4fa";
              text = "#1e1e2e";
              indicator = "#f5e0dc";
              childBorder = "#89b4fa";
            };
            unfocused = {
              border = "#45475a";
              background = "#45475a";
              text = "#cdd6f4";
              indicator = "#45475a";
              childBorder = "#45475a";
            };
          };

          keybindings = {
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "exec ${menu}";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Left" = "focus left";
            "${modifier}+Down" = "focus down";
            "${modifier}+Up" = "focus up";
            "${modifier}+Right" = "focus right";

            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";

            "${modifier}+b" = "splith";
            "${modifier}+v" = "splitv";
            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+f" = "fullscreen";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";
            "${modifier}+a" = "focus parent";

            "${modifier}+r" = "mode resize";
          };

          modes.resize = {
            "h" = "resize shrink width 10px";
            "j" = "resize grow height 10px";
            "k" = "resize shrink height 10px";
            "l" = "resize grow width 10px";
            "Left" = "resize shrink width 10px";
            "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px";
            "Right" = "resize grow width 10px";
            "Return" = "mode default";
            "Escape" = "mode default";
          };

          startup = [
            { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
          ];

          workspaceOutputAssign =
            map (n: { workspace = toString n; output = "DP-2"; }) [ 1 2 3 4 ]
            ++ map (n: { workspace = toString n; output = "HDMI-A-1"; }) [ 5 6 7 8 ];
        };
      };

      home.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
        XDG_SESSION_TYPE = "wayland";
      };
    };
}
