{ den, lib, ... }:

let
  # Same chord as the mac (ctrl-alt-cmd): Ctrl + Alt (Mod1) + Super (Mod4).
  mod = "Ctrl+Mod1+Mod4";

  # 2D left-hand workspace grid; hjkl excluded (navigation).
  grid = [
    "1" "2" "3" "4" "5"
    "q" "w" "e" "r" "t"
    "a" "s" "d" "f" "g"
    "y" "x" "c" "v" "b"
  ];

  workspaceBinds = lib.listToAttrs (map (k: {
    name = "${mod}+${k}";
    value = "workspace ${k}";
  }) grid);

  # keys inside the sticky move mode: Shift+grid moves the window,
  # plain grid just switches workspace
  moveBinds = lib.listToAttrs (map (k: {
    name = "Shift+${k}";
    value = "move container to workspace ${k}";
  }) grid);

  moveSwitchBinds = lib.listToAttrs (map (k: {
    name = k;
    value = "workspace ${k}";
  }) grid);
in
{
  den.aspects.desktop-environment = {
    nixos = { config, pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NIXOS_OZONE_WL = "1";
      };

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraOptions = [ "--unsupported-gpu" ];
      };

      environment.systemPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        rofi
        xdg-utils
        polkit_gnome
        brightnessctl
      ];

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      services.udisks2.enable = true;
      services.gvfs.enable = true;

      security.polkit.enable = true;

      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
            user = "greeter";
          };
        };
      };
    };

    provides.to-users.homeManager = { pkgs, lib, config, ... }:
      lib.mkIf pkgs.stdenv.isLinux {
        home.packages = with pkgs; [
          swaylock
          swayidle
          wl-clipboard
          grim
          slurp
        ];

        programs.rofi = {
          enable = true;
          package = pkgs.rofi;
        };

        programs.satty = {
          enable = true;
          settings.general = {
            initial-tool = "brush";
            resize.mode = "smart";
            output-filename = "${config.home.homeDirectory}/Pictures/Screenshots/satty-%Y-%m-%dT%H-%M-%S.png";
          };
        };

        xdg.configFile."satty/overrides.css".text = ''
          window, .inner_box, .outer_box {
            background-color: black;
          }
          .toolbar {
            color: @headerbar_fg_color;
            background-color: #ddddddaa;
          }
        '';

        wayland.windowManager.sway = {
          enable = true;
          systemd.enable = true;
          xwayland = true;

          config = rec {
            modifier = mod;
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

            # floating_modifier accepts a single modifier only, hence not ${mod}
            floating.modifier = "Mod4";
            floating.criteria = [
              { app_id = "[Ss]atty"; }
            ];

            # sway spawns a default bar when no bar block exists; an
            # invisible one keeps swaybar out of the way for waybar.
            bars = [ { mode = "invisible"; } ];

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

            # deliberately left unbound: reload, exit sway, layout
            # stacking/tabbed/splits, focus parent, focus mode_toggle
            keybindings = {
              "${modifier}+Return" = "exec ${terminal}";
              "${modifier}+Shift+q" = "kill";

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

              "${modifier}+Shift+space" = "floating toggle";

              "${modifier}+Shift+d" = "exec ${menu}";
              "${modifier}+Shift+f" = "fullscreen";
              "${modifier}+Shift+r" = "mode resize";
              "${modifier}+Shift+m" = "mode move";
              "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | satty -f -";

              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

              "Print" = "exec mkdir -p ~/Pictures/Screenshots && grim - | wl-copy";
              "Shift+Print" = "exec mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date -u +%Y-%m-%dT%H-%M-%SZ).png";
            } // workspaceBinds // {
              # drop home-manager's i3-style ws 6-10 defaults
              "${modifier}+6" = null;
              "${modifier}+7" = null;
              "${modifier}+8" = null;
              "${modifier}+9" = null;
              "${modifier}+0" = null;
              "${modifier}+Shift+6" = null;
              "${modifier}+Shift+7" = null;
              "${modifier}+Shift+8" = null;
              "${modifier}+Shift+9" = null;
              "${modifier}+Shift+0" = null;
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

            # sticky: stays until Return/Escape; move several windows in a row
            modes.move = moveBinds // moveSwitchBinds // {
              "h" = "move left";
              "j" = "move down";
              "k" = "move up";
              "l" = "move right";
              "Left" = "move left";
              "Down" = "move down";
              "Up" = "move up";
              "Right" = "move right";
              "Return" = "mode default";
              "Escape" = "mode default";
            };

            startup = [
              { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
            ];

            workspaceAutoBackAndForth = true;
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
  };
}
