{ lib, den, ... }: {
    den.aspects.bootloader = { host, ... }: {
        nixos = {
            boot.loader = {
                systemd-boot = {
                    enable = true;
                    configurationLimit = 20;
                };
                efi.canTouchEfiVariables = true;
                timeout = 5;
            };

            # dual boot
            boot.loader.systemd-boot = {
                windows = lib.optionalAttrs (host ? windowsBootDrive)  {
                "windows" =
                    let
                    # To determine the name of the windows boot drive, boot into edk2 first, then run
                    # `map -c` to get drive aliases, and try out running `FS1:`, then `ls EFI` to check
                    # which alias corresponds to which EFI partition.
                    boot-drive = host.windowsBootDrive;
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