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

    provides.to-users.homeManager = { pkgs, ... }: {
      # the cargo build; stop the service first, only one server may use a data dir
      home.packages = [
        (pkgs.writeShellScriptBin "ois-dev" ''
          exec "$HOME/.cargo/bin/ois-server" "$@"
        '')
      ];
    };
  };
}
