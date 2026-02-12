{
  flake.modules.nixos.firmware = {
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true; # enableAllFirmware depends on this
  };
}
