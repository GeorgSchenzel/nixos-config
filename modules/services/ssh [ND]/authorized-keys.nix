{
  # additionally, in each host feature we define authorizedKeys
  flake.modules.nixos.ssh = {
    users.users.georg.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBVusZfkaiHso94usHMA8ufWvTPgIpSG8lTlVpDKXLy nixos@nixos"
    ];
  };
}
