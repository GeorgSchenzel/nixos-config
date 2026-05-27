{ den, ... }:

{
  den.aspects.cli-tools = {
    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        vim
        git
        tmux
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
  };
}
