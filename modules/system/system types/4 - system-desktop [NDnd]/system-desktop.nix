{
  inputs,
  lib,
  ...
}:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      desktop-environment
    ];

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-desktop
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with inputs.self.modules.darwin; [
      system-cli
    ];

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-desktop
    ];
  };

  flake.modules.homeManager.system-desktop = { pkgs, lib, ... }: {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      desktop-apps
      opencode
      desktop-environment
    ];
  };
}
