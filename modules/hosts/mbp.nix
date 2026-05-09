{ den, ... }:
{
  # host aspect
  den.aspects.mbp = {

    includes = [
      den.aspects.nix
      den.aspects.homeManager
    ];

    # host NixOS configuration
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.hello ];
      };

    # host provides default home environment for its users
    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.vim ];
      };
  };
}
