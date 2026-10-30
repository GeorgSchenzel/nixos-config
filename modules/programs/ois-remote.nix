{ den, ... }:

let
  # the desktop's own key (github.com/GeorgSchenzel.keys), only good for reaching ois
  tunnelKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcgM2cfJ5hFckonbrPxAJdvMGKnfLJl6e1+PXAmseGA";
in
{
  # Temporary until the homelab exists: the desktop reaches the ois of the mbp
  # through an ssh tunnel, at http://localhost:4321 (the desktop doesn't run ois itself).
  den.aspects.ois-remote = {
    darwin = {
      networking.localHostName = "mbp"; # reachable as mbp.local

      services.openssh = {
        enable = true;
        extraConfig = ''
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PermitRootLogin no
        '';
      };

      users.users.georg.openssh.authorizedKeys.keys = [
        ''restrict,port-forwarding,permitopen="localhost:4321" ${tunnelKey}''
      ];
    };

    nixos = {
      # resolve mbp.local
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    };

    provides.to-users.homeManager = { lib, pkgs, ... }: lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.ois-tunnel = {
        Unit = {
          Description = "ssh tunnel to the ois of the mbp";
          After = [ "network-online.target" ];
        };
        Service = {
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.openssh}/bin/ssh -N"
            "-L 127.0.0.1:4321:localhost:4321"
            "-i %h/.ssh/id_ed25519 -o IdentitiesOnly=yes"
            "-o StrictHostKeyChecking=accept-new"
            "-o ExitOnForwardFailure=yes"
            "-o ServerAliveInterval=15 -o ServerAliveCountMax=3"
            "georg@mbp.local"
          ];
          Restart = "always";
          RestartSec = 10;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
