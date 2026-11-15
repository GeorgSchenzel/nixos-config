{ den, inputs, ... }:

{
  flake-file.inputs.wok.url = "git+ssh://git@github.com/GeorgSchenzel/wok";

  den.aspects.wok = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }: {
      imports = [ inputs.wok.homeManagerModules.default ];

      # socket-activated GPU job daemon on ~/.local/share/wok/wok.sock;
      # jailTools keep the module's default (sway, grim, coreutils, bash).
      # Nothing persisted: the socket dir is recreated per boot, job
      # results are downloaded by clients.
      services.wok.enable = true;
    };
  };
}
