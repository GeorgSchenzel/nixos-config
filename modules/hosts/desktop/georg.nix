{ den, inputs, ... }: {

    den.aspects.desktop = { host, ... }: {
        nixos = {
            home-manager.users.georg = { pkgs, ... }: {
                programs.git = {
                    enable = true;
                    # gitFull ships git-credential-libsecret in exec-path,
                    # which unity hub probes for token persistence.
                    package = pkgs.gitFull;
                    userName = "Georg Schenzel";
                    userEmail = "schenzel.georg@gmail.com";
                };
            };
        };
    };
}
