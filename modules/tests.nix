{ den, lib, ... }: {
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
                {
                    assertion = config.nixpkgs.config.allowUnfree == true;
                    message = "allowUnfree is enabled";
                }
                {
                    assertion = builtins.any (f: f.file == "/etc/machine-id") config.environment.persistence."/persist/system".files;
                    message = "/etc/machine-id must be persisted under /persist/system";
                }
                {
                    assertion = builtins.any (f: f.directory == "/var/log") config.environment.persistence."/persist/system".directories;
                    message = "/var/log must be persisted under /persist/system";
                }
                {
                    assertion = builtins.any (d: d.directory == "nixos-config")
                        config.home-manager.users.georg.home.persistence."/persist/home".directories;
                    message = "nixos-config must be persisted under /persist/home for georg on desktop";
                }
            ];
        };
    };
}