{ den, ... }:

let
  # Same chord as the mac (ctrl-alt-cmd): Ctrl + Alt (Mod1) + Super (Mod4).
  mod = "Ctrl+Mod1+Mod4";
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

              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

              "Print" = "exec mkdir -p ~/Pictures/Screenshots && grim - | wl-copy";
              "Shift+Print" = "exec mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date -u +%Y-%m-%dT%H-%M-%SZ).png";
              "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | satty -f -";
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
          };

          extraConfig = ''
            set $mod ${mod}

            ### workrooms: 5 rooms × 5 slots (11–55), commons 60–100
            # NOTE: reload resets $workroom/$workspace to 1/1 (set lines re-run);
            #       press mod+F after a reload. Daemon will re-sync later.

            set $workroom 1
            set $workspace 1
            # $wsN constants are load-bearing: $$workroom1 would resolve as one
            # variable name. The digit must come from a separate runtime expansion.
            set $ws1 1
            set $ws2 2
            set $ws3 3
            set $ws4 4
            set $ws5 5

            # commons — static, tool-independent
            bindsym $mod+6 workspace number 60
            bindsym $mod+7 workspace number 70
            bindsym $mod+8 workspace number 80
            bindsym $mod+9 workspace number 90
            bindsym $mod+0 workspace number 100
            bindsym $mod+Shift+6 move container to workspace number 60
            bindsym $mod+Shift+7 move container to workspace number 70
            bindsym $mod+Shift+8 move container to workspace number 80
            bindsym $mod+Shift+9 move container to workspace number 90
            bindsym $mod+Shift+0 move container to workspace number 100

            # slot within current room; remember last visited slot (global, not per-room)
            bindsym $mod+1 workspace number $$workroom$ws1; set $$workspace $ws1
            bindsym $mod+2 workspace number $$workroom$ws2; set $$workspace $ws2
            bindsym $mod+3 workspace number $$workroom$ws3; set $$workspace $ws3
            bindsym $mod+4 workspace number $$workroom$ws4; set $$workspace $ws4
            bindsym $mod+5 workspace number $$workroom$ws5; set $$workspace $ws5

            # move focused window to slot in current room
            bindsym $mod+Shift+1 move container to workspace number $$workroom$ws1
            bindsym $mod+Shift+2 move container to workspace number $$workroom$ws2
            bindsym $mod+Shift+3 move container to workspace number $$workroom$ws3
            bindsym $mod+Shift+4 move container to workspace number $$workroom$ws4
            bindsym $mod+Shift+5 move container to workspace number $$workroom$ws5

            # room switch — lands on last-visited slot
            bindsym $mod+F1 set $$workroom 1; workspace number $$workroom$$workspace
            bindsym $mod+F2 set $$workroom 2; workspace number $$workroom$$workspace
            bindsym $mod+F3 set $$workroom 3; workspace number $$workroom$$workspace
            bindsym $mod+F4 set $$workroom 4; workspace number $$workroom$$workspace
            bindsym $mod+F5 set $$workroom 5; workspace number $$workroom$$workspace
          '';
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
