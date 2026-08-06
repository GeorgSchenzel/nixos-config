{ den, ... }: {
  den.hosts.x86_64-linux.desktop.windowsBootDrive = "HD1f65535a2";
  den.hosts.x86_64-linux.desktop.mainDiskDevice = "/dev/nvme0n1";
  den.hosts.x86_64-linux.desktop.btrfsPartition = "/dev/nvme0n1p2";

  den.aspects.desktop = {

    includes = [
      den.aspects.bootloader
      den.aspects.disko
      den.aspects.nix
      den.aspects.system-defaults
      den.aspects.homeManager
      den.aspects.secrets
      den.aspects.impermanence
      den.aspects.ssh
      den.aspects.firmware
      den.aspects.audio
      den.aspects.vm
      den.aspects.cli-tools-desktop
      den.aspects.ai-tools
      den.aspects.desktop-apps
      den.aspects.desktop-environment
      den.aspects.podman
      den.aspects.neovim
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
      };
  };
}