{ den, ... }: {
    den.aspects.bootloader = {
        nixos = {
            boot.loader = {
            systemd-boot = {
                enable = true;
                configurationLimit = 20;
            };
            efi.canTouchEfiVariables = true;
            timeout = 5;
            };
        };
    };
}