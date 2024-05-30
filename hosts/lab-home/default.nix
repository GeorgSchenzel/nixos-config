# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  config, pkgs, ... 
}:
{
  imports =
    [
      ../../disk-config.nix
      ../../modules/system.nix
      ../../modules/impermanence.nix
      ./hardware-configuration.nix
      ./docker-compose-services.nix
    ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    systemd-boot.enable = true;
  };

  networking.hostName = "lab-home";
  
  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";

  #services with docker
  environment.systemPackages = with pkgs; [
    docker
    gawk
  ];
}
