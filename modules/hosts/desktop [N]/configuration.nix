{ inputs, lib, ... }:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      disko
      systemd-boot
      georg
      system-cli
      impermanence
      sway
    ];

    systemConstants = {
      diskDevice = "/dev/nvme0n1";
      btrfsPartition = "/dev/nvme0n1p2";
    };

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
