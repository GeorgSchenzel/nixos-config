{ config, lib, pkgs, ... }:
{
  virtualisation.docker.enable = true;

  users.users.georg.extraGroups = [ "docker" ];

  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.daemon.settings = {
      experimental = true;
      fixed-cidr-v6 = "fd28:d69d:ee83:1::/64";
      ipv6 = true;
      default-address-pools = [
        { base = "172.17.0.0/12"; size = 16; }
        { base = "fd28:d69d:ee83:1000::/64"; size = 80; }
      ];
  };

  systemd.services.docker-compose-services = {
    description = "Docker Compose Services";
    wantedBy = [ "multi-user.target" ];
    path = [pkgs.gawk pkgs.docker];

    script = ''
      cd /srv/appdata/docker
      source dc.sh
      dc up
    '';

    after = ["docker.service" "docker.socket"];
  };
}