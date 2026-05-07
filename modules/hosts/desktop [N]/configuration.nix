{ inputs, lib, ... }:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      disko
      systemd-boot
      georg
      system-cli
      system-desktop
      impermanence
    ];

    systemConstants = {
      diskDevice = "/dev/nvme0n1";
      btrfsPartition = "/dev/nvme0n1p2";
    };
  };

}
