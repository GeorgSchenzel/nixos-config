{ ... }:

{
  flake.modules.homeManager.sway = { pkgs, ... }: {
    home.packages = with pkgs; [ rofi ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
    };
  };
}
