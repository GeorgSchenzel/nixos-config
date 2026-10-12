{ den, ... }:
{
  den.aspects.game-dev = {
    includes = [ den.aspects.fmod ];

    provides.to-users.homeManager = { pkgs, lib, ... }:
      let
        # TODO(nixpkgs): check if this override can be removed and we can go
        # back to plain `pkgs.unityhub` — removable once nixpkgs ships
        # >= 3.22.2:
        #   nix eval nixpkgs#unityhub.version
        #
        # nixpkgs is stuck at 3.19.5, whose licensing client (1.17.4) is too
        # old for editors bundling 1.18.x (e.g. 6000.3): the editor rejects
        # the hub's shared licensing-client pipe on every launch and demands
        # a license re-acceptance. 3.22.2 also moved the payload from
        # opt/unityhub to usr/lib/unityhub and ships a bare "Exec=unityhub";
        # postPatch reshapes that into the 3.19 layout the nixpkgs
        # expression's installPhase expects.
        unityhub = pkgs.unityhub.overrideAttrs (old: rec {
          version = "3.22.2";
          src = pkgs.fetchurl {
            url = "https://hub-dist.unity3d.com/artifactory/hub-debian-prod-local/pool/main/u/unity/unityhub_amd64/UnityHubSetup-${version}-amd64.deb";
            hash = "sha256-oFI6YvxvIhqc6icso0dxlnH81Rm4sdn/gzo5FN7BIiA=";
          };
           postPatch = ''
             mkdir -p opt
             mv usr/lib/unityhub opt/unityhub
             # let the stock installPhase substitute pick this up
             substituteInPlace usr/share/applications/unityhub.desktop \
               --replace-fail "Exec=unityhub %U" "Exec=/opt/unityhub/unityhub %U"
           '';
         });
      in
      {
        # blender is cross-platform; unityhub is Linux x86_64 only in nixpkgs
        # (FHS env, bundles Editor deps). Guarded so the aspect is safe to
        # include on darwin later (unityhub is a no-op there).
        home.packages = [ pkgs.blender ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ unityhub ];
      };

    # Unity editors + projects (downloaded by Hub), license file, Hub config.
    # Note: the Hub uses lowercase XDG dirs (unityhub/unity3d).
    # Blender user prefs, add-ons and saved layouts live in ~/.config/blender.
    persist-home = {
      directories = [
        ".config/blender"
        "Unity"
        ".config/unityhub"
        ".config/unity3d"
        ".local/share/unityhub"
      ];
    };
  };
}
