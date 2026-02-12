{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop = {
    
    imports = [ inputs.disko.nixosModules.disko ];

    # ensure /home is mounted before user activation script is run and directories are created
    fileSystems."/home".neededForBoot = true;
    
    # the filesystems for the VM are derived directly from the disko config
    # since disko doesn't have a neededForBoot passthru, neededForBoot is false
    # so we have to define it requirement separately for the vm otherwise it won't be mounted in stage 1
    # see: https://github.com/nix-community/disko/issues/192
    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/home".neededForBoot = true;
    };

    disko.devices = {
      disk.main = {
        type = "disk";
        device = /dev/nvme0n1;
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
                    "@" = {
                      mountpoint = "/";
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "@tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [ "nodatacow" ];
                      swap.swapfile.size = "4G";
                    };
                  };
              };
            };
          };
        };
      };
    }; 
  };
}

