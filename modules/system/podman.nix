{ den, ... }: {
  den.aspects.podman = {
    # shared: podman CLI on every platform
    os = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.podman ];
    };

    # native daemonless podman
    nixos = { ... }: {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      virtualisation.containers.registries.search = [ "docker.io" "quay.io" "ghcr.io" ];

      users.users.georg.extraGroups = [ "podman" ];
    };

    # podman machine VM backend
    darwin = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.qemu ];
    };

    persist-system = {
      directories = [ "/var/lib/containers" ];
    };

    persist-home = {
      directories = [ ".local/share/containers" ];
    };
  };
}
