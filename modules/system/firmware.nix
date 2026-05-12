{ den, inputs, ... }: {

    den.aspects.firmware = { host, ... }: {
        nixos = {
          hardware.enableAllFirmware = true;
          hardware.enableRedistributableFirmware = true;
        };
    };
}

