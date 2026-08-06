{ den, ... }: {
  den.aspects.podman = {
    nixos = { ... }: {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    persist-system = {
      directories = [ "/var/lib/containers" ];
    };
  };
}
