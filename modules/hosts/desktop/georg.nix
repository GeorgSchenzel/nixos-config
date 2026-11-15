{ den, inputs, ... }: {

    den.aspects.desktop = { host, ... }: {
        nixos = {
            home-manager.users.georg = { pkgs, ... }: {
                programs.git = {
                    enable = true;
                    # gitFull ships git-credential-libsecret in exec-path,
                    # which unity hub probes for token persistence.
                    package = pkgs.gitFull;
                    # reads ~/.git-credentials (sops-rendered by the stew
                    # aspect): gitlab.com and github.com tokens for stew's
                    # https-normalized remotes
                    settings.credential.helper = "store";
                    settings.user.name = "Georg Schenzel";
                    settings.user.email = "schenzel.georg@gmail.com";
                };
            };
        };
    };
}
