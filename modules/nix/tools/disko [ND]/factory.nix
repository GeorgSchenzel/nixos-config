{
  inputs,
  lib,
  ...
}:
{
  flake.factory.disko-btrfs = device: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices = {
      disk.main = {
        type = "disk";
        device = device;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4G";
                  };
                };
              };
            };
          };
        };
      };
    };

    boot.loader.grub = {
      enable = true;
      devices = [ device ];
    };
  };
}
