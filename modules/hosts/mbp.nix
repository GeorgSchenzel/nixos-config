{ den, ... }:
{
  # host aspect
  den.aspects.mbp = {

    includes = [
      den.aspects.nix
      den.aspects.system-defaults
      den.aspects.homeManager
      den.aspects.secrets
      den.aspects.cli-tools-desktop
      den.aspects.ai-tools
      den.aspects.desktop-apps
      den.aspects.podman
      den.aspects.aerospace
      den.aspects.keybinds
      den.aspects.neovim
      den.aspects.microsandbox
    ];

    # host NixOS configuration
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.hello ];
      };

    # host provides default home environment for its users
    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        targets.darwin.copyApps.enable = true;
      };
  };
}
