{ den, ... }: {
    den.aspects.desktop = {
        nixos = { config, ... }: {
            assertions = [
                {
                    assertion = config.boot.loader.systemd-boot.enable;
                    message = "desktop must use systemd-boot as the boot loader";
                }
                {
                    assertion = config.boot.loader.systemd-boot.windows.windows.efiDeviceHandle == "HD1f65535a2";
                    message = "boot drive must be set to HD1f65535a2 for the windows boot entry";
                }
            ];
        };
    };
}