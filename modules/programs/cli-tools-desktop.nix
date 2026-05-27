{ den, ... }:

{
  den.aspects.cli-tools-desktop = {
    includes = [
      den.aspects.cli-tools
    ];

    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
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
        jdk21
        maven
        quarkus
      ];
    };

    persist-home = {
      files = [
        ".bash_history"
      ];
    };
  };
}
