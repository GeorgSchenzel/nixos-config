{ den, ... }:

{
  den.aspects.cli-tools = {
    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        vim
        git
        ffmpeg
      ];
    };

    nixos = { pkgs, ... }: {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/georg/nixos-config";
      };
    };

    provides.to-users.homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        tika
        pdftk
        openconnect
        kubectl
        kubernetes-helm
        k9s
        nodejs
        bun
        uv
        just
      ];
    };

    persist-home = {
      files = [
        ".bash_history"
      ];
    };
  };
}
