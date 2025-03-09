{
  lib,
  inputs, 
  ...
}:
{
  imports = [inputs.impermanence.nixosModules.impermanence];

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /tmp/btrfs -p
    mount /dev/disk/by-label/main-disk /tmp/btrfs
    if [[ -e /tmp/btrfs/nixos/@root ]]; then
        mkdir -p /tmp/btrfs/nixos/old_roots
        timestamp=$(date --date="@$(stat -c %Y /tmp/btrfs/nixos/@root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /tmp/btrfs/nixos/@root "/tmp/btrfs/nixos/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/tmp/btrfs/nixos/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /tmp/btrfs/nixos/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /tmp/btrfs/nixos/@root
    umount /tmp/btrfs
  '';

  fileSystems."/persistent/system".neededForBoot = true;

  environment.persistence."/persistent/system" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/docker"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"

      #{ file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };
  
  fileSystems."/persistent/server".neededForBoot = true;

  environment.persistence."/persistent/server" = {
    hideMounts = true;
    directories = [
      
    ];
  };

  fileSystems."/persistent/home".neededForBoot = true;

  environment.persistence."/persistent/home" = {
    hideMounts = true;
    directories = [
      
    ];
  };
}