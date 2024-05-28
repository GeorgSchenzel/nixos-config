{
  inputs,
  ...
}:
{
  imports = [inputs.disko.nixosModules.disko];
  
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              start = "1MiB";
              end = "256M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--label main-disk"
                ]; # Override existing partition
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "@persistent/system" = {
                    mountpoint = "/persistent/system";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "@persistent/server" = {
                    mountpoint = "/persistent/server";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "8G";
                    };
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