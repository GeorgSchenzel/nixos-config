{ den, inputs, ... }:
{
    den.aspects.homeManager = { user, ... }: {
        provides.to-users.homeManager = { config, pkgs, lib, ... }:
        {
            home.homeDirectory =
                if pkgs.stdenv.isDarwin then
                (lib.mkForce "/Users/${user.userName}")
                else
                "/home/${user.userName}";
            home.stateVersion = "25.11";
        };
    };
}