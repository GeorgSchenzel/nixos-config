# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  config, pkgs, ... 
}:
{
  imports =
    [
      ./disk-config.nix
      ../../modules/system.nix
      ../../modules/impermanence.nix
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
#    systemd-boot = {
#      enable = true;
#      extraEntries = {
#        "arch.conf" = ''
#          title Arch
#          linux /arch/vmlinuz-linux
#          initrd /arch/initramfs-linux.img
#          options root=UUID=fa985b3a-3c9b-4f0e-bc04-e7c16b54b584 rootflags=subvol=/arch/@root rw
#        '';
#      };
#    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      extraEntries = ''
        menuentry "Arch" {
          insmod part_gpt
          insmod btrfs
          search --no-floppy --fs-uuid --set=root fa985b3a-3c9b-4f0e-bc04-e7c16b54b584
          linux /arch/@root/boot/vmlinuz-linux root=UUID=fa985b3a-3c9b-4f0e-bc04-e7c16b54b584 rootflags=subvol=/arch/@root rw
          initrd /arch/@root/boot/initramfs-custom.img
        }
      '';
    };
  };

  networking.hostName = "desktop";
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "24.11";

  #services with docker
  environment.systemPackages = with pkgs; [
    docker
    gawk
    kitty
  ];
}
