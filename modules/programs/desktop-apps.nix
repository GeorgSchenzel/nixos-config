{ den, ... }:

{
  den.aspects.desktop-apps = {
    # ship the terminfo of common terminals (xterm-ghostty & co) system-wide;
    # without it zsh line editing breaks in terminals whose $TERM has no
    # terminfo entry (cursor overwrites text, broken completion)
    nixos = {
      environment.enableAllTerminfo = true;
    };

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
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        nautilus
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        iina
      ];

      programs.alacritty.enable = true;
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
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
