{ den, ... }: {
  den.aspects.podman = {
    nixos = { ... }: {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.georg.extraGroups = [ "podman" ];
    };

    persist-system = {
      directories = [ "/var/lib/containers" ];
    };
  };
}
