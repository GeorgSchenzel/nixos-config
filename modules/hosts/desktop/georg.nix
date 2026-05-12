{ den, inputs, ... }: {

    den.aspects.desktop = { host, ... }: {
        nixos = {
            home-manager.users.georg = {
                programs.git = {
                    enable = true;
                    userName = "Georg Schenzel";
                    userEmail = "schenzel.georg@gmail.com";
                };
            };
        };
    };
}
