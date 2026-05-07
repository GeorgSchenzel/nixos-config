{ inputs, ... }:
{
  flake.lib = {
    mkIfPersistence =
      config: settings:
      if config ? home then
        (if config.home ? persistence then settings else { })
      else
        (if config.environment ? persistence then settings else { });
  };

  flake.modules.nixos.impermanence = { pkgs, ... }: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "show-changed";
        runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.gnugrep pkgs.gnused ];
        bashOptions = [ ];
        text = ''
          echo "=== Home - unpersisted files (3-level summary) ==="
          find /home -xdev -type f ! -type l 2>/dev/null \
            | grep -v '^/persist' \
            | sed 's|^/home/[^/]*/||' \
            | cut -d'/' -f1-3 \
            | sort | uniq -c | sort -rn

          echo ""
          echo "=== System - unpersisted files (3-level summary) ==="
          find / -xdev -type f ! -type l 2>/dev/null \
            | grep -v '^/persist\|^/proc\|^/sys\|^/dev\|^/home' \
            | sed 's|^/||' \
            | cut -d'/' -f1-3 \
            | sort | uniq -c | sort -rn

          echo ""
          echo "=== Home - unpersisted directories (3-level summary) ==="
          find /home -xdev -type d ! -type l 2>/dev/null \
            | grep -v '^/persist' \
            | sed 's|^/home/[^/]*/||' \
            | cut -d'/' -f1-3 \
            | sort | uniq -c | sort -rn

          echo ""
          echo "=== System - unpersisted directories (3-level summary) ==="
          find / -xdev -type d ! -type l 2>/dev/null \
            | grep -v '^/persist\|^/proc\|^/sys\|^/dev\|^/home' \
            | sed 's|^/||' \
            | cut -d'/' -f1-3 \
            | sort | uniq -c | sort -rn
        '';
      })
    ];
  };
}
