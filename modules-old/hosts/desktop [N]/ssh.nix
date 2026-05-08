{
  flake.modules.nixos.ssh = {
    users.users.georg.openssh.authorizedKeys.keys = [
      # TODO: Add desktop host public key here after generating
      # e.g. "ssh-ed25519 AAAA... desktop"
    ];
  };
}
