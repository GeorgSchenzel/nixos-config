{ lib, den, ... }:
{
  den.default.nixos.system.stateVersion = "25.11";
  den.default.darwin.system.stateVersion = 6;
  den.default.homeManager.home.stateVersion = "25.11";

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [ den.provides.mutual-provider ];

  # User TODO: REMOVE THIS
  den.aspects.georg.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/fake";
    fileSystems."/".fsType = "auto";
  };
}
