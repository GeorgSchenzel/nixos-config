{ den, ... }: {

    den.aspects.ssh = {
        nixos = {
            services.openssh = {
                enable = true;
                openFirewall = true;
                settings = {
                    PasswordAuthentication = false;
                    PermitRootLogin = "no";
                    KbdInteractiveAuthentication = false;
                };
            };
        };

        persist-system = {
            files = [
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
            ];
        };

        persist-home = {
            directories = [
                ".ssh"
            ];
        };
    };
}