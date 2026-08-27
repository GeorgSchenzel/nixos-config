{ den, lib, ... }:

{
  # Per-host keyboard customization. Currently: caps = ctrl+alt (hold), esc (tap).
  # The darwin part (Karabiner) applies wherever this aspect is included on a
  # mac; a future nixos part (e.g. services.keyd) can define different binds.
  den.aspects.keybinds = {
    darwin =
      { pkgs, ... }:
      {
        # 14.x: nix-darwin's module doesn't support the 15.x app architecture
        # (nix-darwin#1041, fix pending in #1679). Revisit when that lands.
        services.karabiner-elements = {
          enable = true;
          package = pkgs.karabiner-elements.overrideAttrs (old: {
            version = "14.13.0";
            src = pkgs.fetchurl {
              url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v14.13.0/Karabiner-Elements-14.13.0.dmg";
              hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
            };
          });
        };
      };

    provides.to-users.homeManager =
      { pkgs, lib, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        # NB: managed declaratively — edits made in Karabiner's GUI cannot be
        # saved back (the file is a read-only symlink into the store).
        xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
          profiles = [
            {
              name = "Default";
              selected = true;
              complex_modifications.rules = [
                {
                  description = "Caps Lock: hold = ctrl+alt, tap = escape";
                  manipulators = [
                    {
                      type = "basic";
                      from = {
                        key_code = "caps_lock";
                        modifiers.optional = [ "any" ];
                      };
                      to = [
                        {
                          key_code = "left_control";
                          modifiers = [ "left_option" ];
                        }
                      ];
                      to_if_alone = [ { key_code = "escape"; } ];
                      parameters."basic.to_if_alone_timeout_milliseconds" = 300;
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
  };
}
