{ ... }:

{
  flake.modules.nixos.systemd-boot = {
    boot.loader = {
      systemd-boot = {
        windows = {
          "windows" =
            let
              # To determine the name of the windows boot drive, boot into edk2 first, then run
              # `map -c` to get drive aliases, and try out running `FS1:`, then `ls EFI` to check
              # which alias corresponds to which EFI partition.
              boot-drive = "HD1f65535a2";
            in
            {
              title = "Windows";
              efiDeviceHandle = boot-drive;
              sortKey = "y_windows";
            };
        };

        edk2-uefi-shell.enable = true;
        edk2-uefi-shell.sortKey = "z_edk2";
      };
    };
  };
 }
