{ lib, ... }:
{
  flake.modules.nixos.impermanence = { config, ... }:
  {
    boot.initrd.systemd = 
    let
      # Convert /dev/vda2 to dev-vda2.device format
      deviceUnit = "${lib.replaceStrings ["/dev/"] ["dev-"] config.systemConstants.btrfsPartition}.device";
    in
    {
      enable = true;
      services.rollback = {
        description = "Rollback BTRFS root subvolume";
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        after = [ deviceUnit ];
        requires = [ deviceUnit ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir /btrfs_tmp
          mount -t btrfs ${config.systemConstants.btrfsPartition} /btrfs_tmp

          # Delete nested subvolumes first
          btrfs subvolume list -o /btrfs_tmp/@ | cut -f9 -d' ' | while read subvolume; do
            btrfs subvolume delete "/btrfs_tmp/$subvolume"
          done

          if [[ -e /btrfs_tmp/@ ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
            btrfs subvolume delete /btrfs_tmp/@
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/@
          umount /btrfs_tmp
        '';
      };
    };
  };
}
