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
