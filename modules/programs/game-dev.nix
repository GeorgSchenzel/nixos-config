{ den, ... }:
{
  den.aspects.game-dev = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      # unityhub is Linux x86_64 only in nixpkgs (FHS env, bundles Editor deps).
      # Guarded so the aspect is safe to include on darwin later (no-op there).
      home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.unityhub ];
    };

    # Unity editors + projects (downloaded by Hub), license file, Hub config.
    persist-home = {
      directories = [
        "Unity"
        ".local/share/unity3d"
        ".config/UnityHub"
      ];
    };
  };
}
