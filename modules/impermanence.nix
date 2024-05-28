{
  lib,
  inputs, 
  ...
}:
{
  imports = [inputs.impermanence.nixosModules.impermanence];

  #fileSystems."/" = {
  #  device = "/dev/disk/by-label/main-disk";
  #  fsType = "btrfs";
  #  options = [ "subvol=root" ];
  #};

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /tmp/btrfs -p
    mount /dev/disk/by-label/main-disk /tmp/btrfs
    if [[ -e /tmp/btrfs/@ ]]; then
        mkdir -p /tmp/btrfs/old_roots
        timestamp=$(date --date="@$(stat -c %Y /tmp/btrfs/@)" "+%Y-%m-%-d_%H:%M:%S")
        mv /tmp/btrfs/@ "/tmp/btrfs/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/tmp/btrfs/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /tmp/btrfs/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /tmp/btrfs/@
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
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };
  
  fileSystems."/persistent/server".neededForBoot = true;

  environment.persistence."/persistent/server" = {
    hideMounts = true;
    directories = [
      "/srv"
    ];
  };
}