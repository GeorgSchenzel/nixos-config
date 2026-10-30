{ den, lib, ... }:
{
  # user aspect
  den.aspects.georg = { host, ... }: {
    includes = [
      den.aspects.shell-aliases
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "zsh")
      # den._.host-aspects # allows host-aspects to fill homeManager by default, not used
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.htop ];
        # ~/.local/bin on PATH for every interactive shell (login or not):
        # hm-session-vars.sh is sourced from ~/.bashrc, so terminals under
        # sway (which never see /etc/profile) still get it.
        home.sessionPath = [ "$HOME/.local/bin" ];
      };

    persist-home = {
      directories = [
        "nixos-config"
        "hot"
        "vaults"
      ];
    };

    # user can provide NixOS configurations
    # to any host it is included on
    provides.to-hosts.nixos = { pkgs, ... }: {
      users.users.georg.password = "password";
      users.users.georg.extraGroups = [ "kvm" ];
    };
  };
}
