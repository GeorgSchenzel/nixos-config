{ den, ... }:
{
  # user aspect
  den.aspects.georg = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "bash")
      # den._.host-aspects # allows host-aspects to fill homeManager by default, not used
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.htop ];
      };

    persist-home = {
      directories = [
        "nixos-config"
        "hot"
      ];
    };

    # user can provide NixOS configurations
    # to any host it is included on
    provides.to-hosts.nixos = { pkgs, ... }: {
      users.users.georg.password = "password";
    };
  };
}
