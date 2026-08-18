{ den, ... }:

{
  den.aspects.cli-tools = {
    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        git
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

    provides.to-users.homeManager = { pkgs, lib, ... }: {
      
      home.packages = with pkgs; [
        lazygit
      ];


      programs.tmux = {
        enable = true;
        mouse = true;
        keyMode = "vi";
      };

      programs.zellij.enable = true;
    };
  };
}
