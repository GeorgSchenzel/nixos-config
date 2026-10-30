{ den, inputs, ... }:

{
  flake-file.inputs.ois.url = "git+ssh://git@github.com/GeorgSchenzel/ois";

  # ois server on http://localhost:4321; a launchd agent of the user on darwin
  # (data in ~/Library/Application Support/ois), a systemd service on nixos.
  den.aspects.ois = {
    darwin = {
      imports = [ inputs.ois.darwinModules.default ];
      services.ois.enable = true;
    };

    nixos = {
      imports = [ inputs.ois.nixosModules.default ];
      services.ois.enable = true;
    };

    # data and snapshots of the nixos service
    persist-system.directories = [ "/var/lib/ois" ];

    provides.to-users.homeManager = { config, lib, pkgs, ... }:
      let
        secrets = config.sops.secrets;
        # one shared repo for all devices and data sets: told apart by --host and --tag.
        # The repo url (it holds the storage box account), its password and the pinned
        # host key are sops secrets; see secrets/example.yaml.
        env = ''
          export PATH=${lib.makeBinPath [ pkgs.restic pkgs.openssh pkgs.coreutils ]}:$PATH
          export RESTIC_REPOSITORY_FILE=${secrets."restic/repository".path}
          export RESTIC_PASSWORD_FILE=${secrets."restic/password".path}
          opts=(-o "sftp.args=-F /dev/null -p 23 -i $HOME/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=${secrets."restic/known_hosts".path}")
          dir="$HOME/Library/Application Support/ois"
        '';
        backup = pkgs.writeShellScript "ois-restic-backup" ''
          set -euo pipefail
          ${env}
          # the live database is excluded: snapshots/ holds its consistent copies
          restic "''${opts[@]}" backup --host mbp --tag ois \
            --exclude "$dir/data/ois.db" --exclude "$dir/data/ois.db-wal" --exclude "$dir/data/ois.db-shm" \
            "$dir"
          restic "''${opts[@]}" forget --host mbp --tag ois --group-by host,tags \
            --keep-hourly 24 --keep-daily 7 --keep-weekly 4 --keep-monthly unlimited --prune
        '';
        # Restores a backup into a temp folder and serves it on another port, to look at it.
        # Never touches the real data dir: restoring is copying the snapshot over data/ois.db.
        open = pkgs.writeShellScriptBin "ois-backup-open" ''
          set -euo pipefail
          ${env}
          tmp=$(mktemp -d)
          trap 'rm -rf "$tmp"' EXIT
          restic "''${opts[@]}" restore "''${1:-latest}" --host mbp --tag ois --target "$tmp"
          restored="$tmp$dir"
          # the newest by name: the names hold the timestamp
          snapshot=$(find "$restored/snapshots" -name 'ois-*.db' | awk -F/ '{ print $NF " " $0 }' | sort | tail -1 | cut -d' ' -f2-)
          echo "restored snapshot: $snapshot"
          mkdir -p "$restored/data"
          cp "$snapshot" "$restored/data/ois.db"
          echo "serving on http://localhost:4322, ctrl-c to stop and delete the copy"
          OIS_DATA="$restored/data" OIS_SNAPSHOTS="$restored/snapshots" PORT=4322 \
            ${lib.getExe inputs.ois.packages.${pkgs.stdenv.hostPlatform.system}.default}
        '';
      in
      {
        # the cargo build; stop the service first, only one server may use a data dir
        home.packages = [
          (pkgs.writeShellScriptBin "ois-dev" ''
            exec "$HOME/.cargo/bin/ois-server" "$@"
          '')
        ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          open
          (pkgs.writeShellScriptBin "ois-backup-now" "exec ${backup}")
        ];

        sops.secrets = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "restic/repository" = { };
          "restic/password" = { };
          "restic/known_hosts" = { };
        };

        # hourly; a run missed while the secrets weren't decrypted yet just waits for the next
        launchd.agents.ois-restic = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = true;
          config = {
            ProgramArguments = [ "${backup}" ];
            StartInterval = 3600;
            RunAtLoad = true;
            ProcessType = "Background";
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/restic-ois.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/restic-ois.log";
          };
        };
      };
  };
}
