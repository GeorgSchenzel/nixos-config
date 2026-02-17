{
  flake.modules.homeManager.desktop-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        firefox
        thunderbird
        vscode
      ];

      programs.alacritty.enable = true;
    };
}
