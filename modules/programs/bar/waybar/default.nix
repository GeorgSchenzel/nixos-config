{ den, lib, ... }:

{
  # The sway bar (linux). The aerospace counterpart (darwin) will live in
  # bar/sketchybar/ with its own plugins — scripts are per-bar, not shared.
  # WM-specific widget logic stays here; a future dashboard/agent-state tool
  # will own the sway-vs-aerospace abstraction and replace
  # workspace-grid.sh with its own data feed.
  den.aspects.waybar = {
    provides.to-users.homeManager =
      { pkgs, ... }:
      lib.mkIf pkgs.stdenv.isLinux (
        let
          # plain bash files next to this module — no nix-string escaping
          workspaceGrid = pkgs.writeShellApplication {
            name = "waybar-workspace-grid";
            runtimeInputs = with pkgs; [ sway jq ];
            text = builtins.readFile ./workspace-grid.sh;
          };

          # successor of the i3status read_file voxtype module
          dictationWidget = pkgs.writeShellApplication {
            name = "waybar-dictation";
            runtimeInputs = [ pkgs.jq ];
            text = builtins.readFile ./dictation.sh;
          };
        in
        {
          programs.waybar = {
            enable = true;
            systemd.enable = true;

            settings.main = {
              position = "bottom";
              # waybar refuses less than 68 with the 3-row grid module
              height = 68;

              modules-left = [
                "custom/grid"
                "sway/workspaces"
              ];
              modules-right = [
                "sway/mode"
                "custom/dictation"
                "tray"
                "clock"
              ];

              "sway/workspaces" = {
                all-outputs = true;
              };

              "custom/grid" = {
                exec = "${workspaceGrid}/bin/waybar-workspace-grid";
                restart-interval = 3;
                return-type = "json";
              };

              "custom/dictation" = {
                exec = "${dictationWidget}/bin/waybar-dictation";
                interval = 1;
                return-type = "json";
              };

              clock = {
                format = "{:%H:%M}";
                tooltip-format = "{:%Y-%m-%d}";
              };

              tray.spacing = 8;
            };

            style = ''
              * {
                border: none;
                border-radius: 0;
                min-height: 0;
              }

              window#waybar {
                background: #1e1e2e;
                color: #cdd6f4;
                font-family: monospace;
                font-size: 13px;
              }

              #custom-grid {
                font-size: 11px;
                padding: 0 8px;
              }

              #workspaces button {
                color: #cdd6f4;
                padding: 0 6px;
              }

              #workspaces button.focused {
                background: #89b4fa;
                color: #1e1e2e;
              }

              #sway-mode {
                color: #f5e0dc;
                font-weight: bold;
                padding: 0 10px;
              }

              #custom-dictation {
                color: #a6e3a1;
                padding: 0 10px;
              }

              #custom-dictation.empty {
                padding: 0;
              }

              #tray,
              #clock {
                padding: 0 10px;
              }

              #clock {
                color: #89b4fa;
              }
            '';
          };
        }
      );
  };
}
