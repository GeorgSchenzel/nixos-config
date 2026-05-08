{ inputs, lib, ... }:
{
  flake.modules.nixos.desktop = {

    virtualisation.vmVariantWithDisko = {
      systemConstants = lib.mkForce {
        diskDevice = "/dev/vda";
        btrfsPartition = "/dev/vda2";
      };
      virtualisation.forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ];
      security.sudo.wheelNeedsPassword = false;
    };
  };
}
