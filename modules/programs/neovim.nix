{ den, inputs, ... }:

{
  flake-file.inputs.nix-wrapper-modules = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.neovim = {
    os = { pkgs, ... }: {
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

    provides.to-users.homeManager = { pkgs, ... }:
      let
        wrappedNvim = inputs.nix-wrapper-modules.wrappers.neovim.wrap {
          inherit pkgs;
          settings.config_directory = ./nvim;
          # settings.config_directory = "/home/georg/nixos-config/modules/programs/nvim"; # dev: live edits, no rebuild
          settings.aliases = [ "vi" "vim" ];
          specs = { };
          runtimePkgs = [ ];
        };
      in
      {
        home.packages = [ wrappedNvim ];
      };

    persist-home = {
      directories = [ ".local/state/nvim" ];
    };
  };
}
