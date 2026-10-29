{ den, inputs, ... }:
{
    den.aspects.homeManager = { user, ... }: {
        os = {
            home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
            };
        };
        
        provides.to-users.homeManager = { config, pkgs, lib, ... }:
        {
            home.homeDirectory =
                if pkgs.stdenv.hostPlatform.isDarwin then
                (lib.mkForce "/Users/${user.userName}")
                else
                "/home/${user.userName}";
            home.stateVersion = "25.11";
        };
    };
}