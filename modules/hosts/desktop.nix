{ den, ... }: {
  den.hosts.x86_64-linux.desktop.windowsBootDrive = "HD1f65535a2";
  den.hosts.x86_64-linux.desktop.mainDiskDevice = "/dev/nvme0n1";

  den.aspects.desktop = {

    includes = [
      den.aspects.bootloader
      den.aspects.disko
      den.aspects.nix
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
        home.packages = [ pkgs.vim ];
      };
  };
}