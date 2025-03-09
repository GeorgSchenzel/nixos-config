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
        device = "/dev/nvme0n1";
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
                  "nixos/@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "nixos/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "nixos/@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "nixos/@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "nixos/@persistent/system" = {
                    mountpoint = "/persistent/system";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "nixos/@persistent/server" = {
                    mountpoint = "/persistent/server";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "nixos/@persistent/home" = {
                    mountpoint = "/persistent/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    mountOptions = [ "compress=zstd" "noatime" ];
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
