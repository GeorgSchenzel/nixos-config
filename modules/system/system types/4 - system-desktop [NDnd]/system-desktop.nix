{
  inputs,
  lib,
  ...
}:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      desktop-environment
    ];

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-desktop
    ];
  };

  flake.modules.darwin.system-desktop = {
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-desktop
    ];
  };

  flake.modules.homeManager.system-desktop = { pkgs, lib, ... }: {
    imports = with inputs.self.modules.homeManager; [
      desktop-apps
      ai-tools
      desktop-environment
    ];
  };
}
