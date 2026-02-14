{ inputs, ... }:

{
  flake.modules.nixos.sway = { config, pkgs, ... }: {

    services.greetd = {
        enable = true;
        settings = {
            default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
            user = "greeter";
            };
        };
    };
  };
}