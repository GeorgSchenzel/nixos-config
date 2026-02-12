{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
    ];

    users.users.georg = {
      isNormalUser = true;
      description = "Georg";
      extraGroups = [ "wheel" ];
      password = "password";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
  };
}
