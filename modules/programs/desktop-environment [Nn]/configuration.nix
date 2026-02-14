{ inputs, ... }:

{
  flake.modules.nixos.desktop-environment = { config, pkgs, ... }: {

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.desktop-environment
    ];
  };
}