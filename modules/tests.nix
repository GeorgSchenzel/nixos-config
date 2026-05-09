{ den, ... }: {
    den.aspects.desktop = {
        nixos = { config, ... }: {
            assertions = [{
                assertion = config.boot.loader.systemd-boot.enable;
                message = "desktop must use systemd-boot as the boot loader";
            }];
        };
    };
}