{ den, lib, ... }: {
    den.aspects.desktop = {
        nixos = { config, ... }:
        let
            homeDirs = config.home-manager.users.georg.home.persistence."/persist/home".directories;
            homeFiles = config.home-manager.users.georg.home.persistence."/persist/home".files;
        in {
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

                # system-level persistence (host scope -> nixos class)
                {
                    assertion = builtins.any (f: f.file == "/etc/machine-id") config.environment.persistence."/persist/system".files;
                    message = "/etc/machine-id must be persisted under /persist/system";
                }
                {
                    assertion = builtins.any (f: f.directory == "/var/log") config.environment.persistence."/persist/system".directories;
                    message = "/var/log must be persisted under /persist/system";
                }

                # user-level persistence from user aspect (works: same scope)
                {
                    assertion = builtins.any (d: d.directory == "nixos-config") homeDirs;
                    message = "nixos-config must be persisted under /persist/home for georg on desktop";
                }
                {
                    assertion = builtins.any (d: d.directory == "hot") homeDirs;
                    message = "hot must be persisted under /persist/home for georg on desktop";
                }

                # user-level persistence from host aspects (bug: quirks are scope-local)
                # ai-tools
                {
                    assertion = builtins.any (d: d.directory == ".local/share/opencode") homeDirs;
                    message = ".local/share/opencode must be persisted for opencode config";
                }
                {
                    assertion = builtins.any (d: d.directory == ".local/state/opencode") homeDirs;
                    message = ".local/state/opencode must be persisted for opencode state";
                }
                # desktop-apps
                {
                    assertion = builtins.any (d: d.directory == ".mozilla/firefox") homeDirs;
                    message = ".mozilla/firefox must be persisted for firefox history";
                }
                {
                    assertion = builtins.any (d: d.directory == ".thunderbird") homeDirs;
                    message = ".thunderbird must be persisted";
                }
                {
                    assertion = builtins.any (d: d.directory == ".config/Code") homeDirs;
                    message = ".config/Code must be persisted for VS Code";
                }
                # ssh
                {
                    assertion = builtins.any (d: d.directory == ".ssh") homeDirs;
                    message = ".ssh must be persisted";
                }
                # cli-tools
                {
                    assertion = builtins.any (f: f.file == ".bash_history") homeFiles;
                    message = ".bash_history must be persisted";
                }
            ];
        };
    };
}