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
        signal-desktop
      ] ++ lib.optionals pkgs.stdenv.isLinux [
        nautilus
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        iina
      ];

      programs.alacritty.enable = true;
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      };
    };

    persist-home = {
      directories = [
        ".mozilla/firefox"
        ".thunderbird"
        ".config/Code"
        ".config/obsidian"
      ];
    };

    darwin = {
      homebrew = {
        enable = true;
        casks = [
          "google-chrome"
        ];
      };
    };
  };
}
