{ inputs, ... }:

{
  flake.modules.nixos.desktop-environment = { config, pkgs, ... }: {

    services.greetd = {
        enable = true;
        settings = {
            default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
            user = "greeter";
            };
        };
    };
  };
}