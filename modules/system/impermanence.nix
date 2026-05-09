{ den, lib, inputs, ... }: {

    flake-file.inputs.impermanence.url = "github:nix-community/impermanence";

    den.aspects.impermanence = { host, ... }: {
        nixos = { pkgs, ... }: {
            imports = [ inputs.impermanence.nixosModules.impermanence ];

            # minimum system level persists
            environment.persistence."/persist/system" = {
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

            programs.fuse.userAllowOther = true;


            # rollback service

            boot.initrd.systemd = 
            let
                # Convert /dev/vda2 to dev-vda2.device format
                deviceUnit = "${lib.replaceStrings ["/dev/"] ["dev-"] host.btrfsPartition}.device";
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
                    mount -t btrfs ${host.btrfsPartition} /btrfs_tmp

                    # Delete nested subvolumes first (root)
                    btrfs subvolume list -o /btrfs_tmp/@ | cut -f9 -d' ' | while read subvolume; do
                        btrfs subvolume delete "/btrfs_tmp/$subvolume"
                    done

                    # Delete nested subvolumes first (home)
                    btrfs subvolume list -o /btrfs_tmp/@home | cut -f9 -d' ' | while read subvolume; do
                        btrfs subvolume delete "/btrfs_tmp/$subvolume"
                    done

                    if [[ -e /btrfs_tmp/@ ]]; then
                        mkdir -p /btrfs_tmp/old_roots
                        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
                        mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
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

                    if [[ -e /btrfs_tmp/@home ]]; then
                        mkdir -p /btrfs_tmp/old_roots
                        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@home)" "+%Y-%m-%-d_%H:%M:%S")
                        mv /btrfs_tmp/@home "/btrfs_tmp/old_roots/$timestamp-home"
                    fi

                    btrfs subvolume create /btrfs_tmp/@home
                    umount /btrfs_tmp
                    '';
                };
            };

            # show changes script
            environment.systemPackages = [
                (pkgs.writeShellApplication {
                    name = "show-changed";
                    runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.gnugrep pkgs.gnused ];
                    bashOptions = [ ];
                    text = ''
                    echo "=== Home - unpersisted files (3-level summary) ==="
                    find /home -xdev -type f ! -type l 2>/dev/null \
                        | grep -v '^/persist' \
                        | sed 's|^/home/[^/]*/||' \
                        | cut -d'/' -f1-3 \
                        | sort | uniq -c | sort -rn

                    echo ""
                    echo "=== System - unpersisted files (3-level summary) ==="
                    find / -xdev -type f ! -type l 2>/dev/null \
                        | grep -v '^/persist\|^/proc\|^/sys\|^/dev\|^/home' \
                        | sed 's|^/||' \
                        | cut -d'/' -f1-3 \
                        | sort | uniq -c | sort -rn

                    echo ""
                    echo "=== Home - unpersisted directories (3-level summary) ==="
                    find /home -xdev -type d ! -type l 2>/dev/null \
                        | grep -v '^/persist' \
                        | sed 's|^/home/[^/]*/||' \
                        | cut -d'/' -f1-3 \
                        | sort | uniq -c | sort -rn

                    echo ""
                    echo "=== System - unpersisted directories (3-level summary) ==="
                    find / -xdev -type d ! -type l 2>/dev/null \
                        | grep -v '^/persist\|^/proc\|^/sys\|^/dev\|^/home' \
                        | sed 's|^/||' \
                        | cut -d'/' -f1-3 \
                        | sort | uniq -c | sort -rn
                    '';
                })
            ];
        };
    };
}