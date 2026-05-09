{ den, inputs, ... }: {

    flake-file.inputs.disko.url = "github:nix-community/disko";

    den.aspects.disko ={  host, ... }: {
        nixos = {
            imports = [ inputs.disko.nixosModules.disko ];

            disko.devices = {
            disk.main = {
                type = "disk";
                device = host.mainDiskDevice;
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
                        extraArgs = [ "-L" "nixos" ];
                        subvolumes = {
                        "@" = { mountpoint = "/"; };
                        "@home" = { mountpoint = "/home"; mountOptions = [ "compress=zstd" ]; };
                        "@nix" = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" ]; };
                        "@persist_home" = { mountpoint = "/persist/home"; mountOptions = [ "compress=zstd" ]; };
                        "@persist_system" = { mountpoint = "/persist/system"; mountOptions = [ "compress=zstd" ]; };
                        "@persist_server" = { mountpoint = "/persist/server"; mountOptions = [ "compress=zstd" ]; };
                        "@log" = { mountpoint = "/var/log"; mountOptions = [ "compress=zstd" ]; };
                        "@tmp" = { mountpoint = "/tmp"; mountOptions = [ "compress=zstd" ]; };
                        "@swap" = { mountpoint = "/swap"; mountOptions = [ "nodatacow" ]; swap.swapfile.size = "4G"; };
                        };
                    };
                    };
                };
                };
            };
            };

            fileSystems."/home".neededForBoot = true;
            fileSystems."/persist/home".neededForBoot = true;
            fileSystems."/persist/system".neededForBoot = true;
            fileSystems."/persist/server".neededForBoot = true;
        };
    };
}