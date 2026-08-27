{ den, lib, ... }:

let
  digits = map toString (lib.range 1 9);
  letters = [
    "A" "B" "C" "D" "E" "F" "G" "I" "M" "N" "O" "P"
    "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
  ];
  workspaces = digits ++ letters;

  # ⌃⌥ instead of plain ⌥: on German (QWERTZ) layout, ⌥ composes special
  # characters (@ [ ] { } | € ~ ...). AeroSpace binds are global hotkeys and
  # would swallow those combos system-wide.
  workspaceBinds = lib.listToAttrs (map (ws: {
    name = "ctrl-alt-${lib.toLower ws}";
    value = "workspace ${ws}";
  }) workspaces);
  moveNodeBinds = lib.listToAttrs (map (ws: {
    name = "ctrl-alt-shift-${lib.toLower ws}";
    value = "move-node-to-workspace ${ws}";
  }) workspaces);
in
{
  den.aspects.aerospace = {
    darwin =
      { config, pkgs, ... }:
      let
        # Save/restore window->workspace assignments across AeroSpace restarts
        # (nix-darwin restarts the launchd agent when its config changes).
        # AeroSpace keeps the tree only in memory:
        # https://github.com/nikitabobko/AeroSpace/issues/57
        saveRestore = pkgs.writeShellScriptBin "aerospace-save-restore" ''
          set -eu
          statefile="$HOME/.aerospace-windows.tsv"
          aerospace=${pkgs.aerospace}/bin/aerospace
          case "''${1:-}" in
            save)
              # TODO(order): list-windows sorts alphabetically, restore replays
              # file order (move-node-to-workspace appends last) => restored
              # tree order is wrong (2 windows on a ws get swapped).
              # Fix later: at save time walk true tree order — per non-empty
              # ws: `aerospace workspace <ws>`, then i=0.. `focus --dfs-index $i`
              # + `list-windows --focused --format '%{window-id}'` until focus
              # fails; emit lines in walk order. Restore side stays unchanged.
              tmp=$(mktemp "$statefile.XXXXXX")
              if "$aerospace" list-windows --all --format '%{window-id}|%{workspace}' > "$tmp"; then
                mv "$tmp" "$statefile"
              else
                rm -f "$tmp" # aerospace not running: keep last snapshot
              fi
              ;;
            restore)
              [ -f "$statefile" ] || exit 0
              sleep 1
              # NB: redirect stdin — aerospace reads (and consumes) it otherwise
              while IFS='|' read -r windowid workspace; do
                [ -n "$windowid" ] || continue
                "$aerospace" move-node-to-workspace --window-id "$windowid" "$workspace" </dev/null >/dev/null 2>&1 || true
              done < "$statefile"
              ;;
          esac
        '';
      in
      {
      # AeroSpace recommendations (logout required for spans-displays)
      system.defaults = {
        dock.expose-group-apps = true;
        spaces.spans-displays = true;
      };

      # Snapshot window->workspace state before activation may restart the agent
      system.activationScripts.extraActivation.text = lib.mkAfter ''
        launchctl asuser "$(id -u ${config.system.primaryUser})" \
          sudo -H --user=${config.system.primaryUser} -- \
          ${lib.getExe saveRestore} save || true
      '';

      services.aerospace = {
        enable = true;
        package = pkgs.aerospace;
        settings = {
          config-version = 2;

          after-startup-command = [
            "exec-and-forget ${lib.getExe saveRestore} restore"
          ];

          gaps = {
            inner.horizontal = 10;
            inner.vertical = 10;
            outer.left = 10;
            outer.bottom = 10;
            outer.top = 10;
            outer.right = 10;
          };

          focus-follows-mouse.enabled = true;

          on-window-detected = [
            {
              "if".app-id = "com.apple.systempreferences";
              run = "layout floating";
            }
            # Ghostty uses macOS native tabs, which AeroSpace sees as separate
            # windows (nikitabobko/AeroSpace#68). Force tiling per
            # https://ghostty.org/docs/help/macos-tiling-wms
            {
              "if".app-id = "com.mitchellh.ghostty";
              run = "layout tiling";
            }
          ];

          persistent-workspaces = workspaces;

          mode.main.binding = {
            "ctrl-alt-enter" = "exec-and-forget open -na Ghostty";
            "ctrl-alt-slash" = "layout tiles horizontal vertical";
            "ctrl-alt-comma" = "layout accordion horizontal vertical";
            "ctrl-alt-h" = "focus left";
            "ctrl-alt-j" = "focus down";
            "ctrl-alt-k" = "focus up";
            "ctrl-alt-l" = "focus right";
            "ctrl-alt-shift-h" = "move left";
            "ctrl-alt-shift-j" = "move down";
            "ctrl-alt-shift-k" = "move up";
            "ctrl-alt-shift-l" = "move right";
            "ctrl-alt-minus" = "resize smart -50";
            "ctrl-alt-equal" = "resize smart +50";
            "ctrl-alt-tab" = "workspace-back-and-forth";
            "ctrl-alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";
            "ctrl-alt-shift-semicolon" = "mode service";
          } // workspaceBinds // moveNodeBinds;

          mode.service.binding = {
            esc = [ "reload-config" "mode main" ];
            r = [ "flatten-workspace-tree" "mode main" ];
            f = [ "layout floating tiling" "mode main" ];
            backspace = [ "close-all-windows-but-current" "mode main" ];
            "ctrl-alt-shift-h" = [ "join-with left" "mode main" ];
            "ctrl-alt-shift-j" = [ "join-with down" "mode main" ];
            "ctrl-alt-shift-k" = [ "join-with up" "mode main" ];
            "ctrl-alt-shift-l" = [ "join-with right" "mode main" ];
          };
        };
      };
    };
  };
}
