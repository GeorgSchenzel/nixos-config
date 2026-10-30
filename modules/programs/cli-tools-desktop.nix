{ den, ... }:

{
  den.aspects.cli-tools-desktop = {
    includes = [
      den.aspects.cli-tools
    ];

    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        ffmpeg
        devenv
      ];
    };

    provides.to-users.homeManager = { pkgs, ... }: {
      # native devenv auto-activation on cd (devenv >= 2.0, replaces direnv);
      # projects must be trusted once with `devenv allow`
      programs.zsh.initContent = ''eval "$(devenv hook zsh)"'';
      programs.bash.initExtra = ''eval "$(devenv hook bash)"'';

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
        glab
      ];
    };

    persist-home = {
      directories = [
        ".local/share/zsh" # zsh history, see shell-aliases
        ".local/share/devenv" # `devenv allow` trust list, gc roots
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
