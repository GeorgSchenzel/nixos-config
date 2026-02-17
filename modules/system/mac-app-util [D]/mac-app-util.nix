{ inputs, ... }:
{
  flake.modules.darwin.mac-app-util = {
    imports = [
      inputs.mac-app-util.darwinModules.default
    ];
  };

  flake.modules.homeManager.mac-app-util = {
    imports = [
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
