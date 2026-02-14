{ inputs, lib, ... }:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      disko
      systemd-boot
      georg
      system-desktop
      impermanence
    ];

    systemConstants = {
      diskDevice = "/dev/nvme0n1";
      btrfsPartition = "/dev/nvme0n1p2";
    };
  };

  flake.modules.homeManager.desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-desktop
    ];
  };
}
