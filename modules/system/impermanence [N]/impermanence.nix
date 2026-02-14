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
        runtimeInputs = [ pkgs.tree ];
        bashOptions = [ ];
        text = ''
          echo "=== System (root) - unpersisted files ==="
          find / -xdev -type f ! -type l 2>/dev/null | grep -v '^/persist' | sort | head -100

          echo ""
          echo "=== Home - unpersisted files ==="
          find /home -xdev -type f ! -type l 2>/dev/null | grep -v '^/persist' | sort | head -100

          echo ""
          echo "=== System - unpersisted directories ==="
          find / -xdev -type d ! -type l 2>/dev/null | grep -v '^/persist' | grep -v '^/proc\|^/sys\|^/dev' | sort | head -50

          echo ""
          echo "=== Home - unpersisted directories ==="
          find /home -xdev -type d ! -type l 2>/dev/null | grep -v '^/persist' | sort | head -50
        '';
      })
    ];
  };
}
