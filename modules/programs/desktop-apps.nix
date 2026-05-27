{ den, ... }:

{
  den.aspects.desktop-apps = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      home.packages = with pkgs; [
        firefox
        thunderbird
        vscode
        obsidian
        jetbrains.pycharm
        jetbrains.idea
        qbittorrent
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        iina
      ];

      programs.alacritty.enable = true;
    };

    persist-home = {
      directories = [
        ".mozilla/firefox"
        ".thunderbird"
        ".config/Code"
      ];
    };
  };
}
