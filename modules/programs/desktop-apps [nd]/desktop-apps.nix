{
  flake.modules.homeManager.desktop-apps = { lib, pkgs, ... }: {
    home.packages = with pkgs; [
      firefox
      thunderbird
      vscode
      obsidian
      jetbrains.pycharm
      qbittorrent
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      iina
    ];

    programs.alacritty.enable = true;
  };
}
