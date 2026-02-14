{ ... }:

{
  flake.modules.homeManager.desktop-environment = { pkgs, ... }: {
    home.packages = with pkgs; [ rofi ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
    };
  };
}
