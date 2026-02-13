{ inputs, ... }:
{
  flake.modules.nixos.impermanence = { config, ... }: {
    fileSystems."/persist".neededForBoot = true;

    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/persist".neededForBoot = true;
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    home-manager.sharedModules = [
      {
        home.persistence."/persist" = {
        };
      }
    ];

    programs.fuse.userAllowOther = true;
  };
}
