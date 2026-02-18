{
  flake.modules.nixos.ssh = {
    users.users.georg.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGd4sJhZmHaQQnx545bulIYGeN96f5NOmgrinQ4A+TdD georg@e254-190.eduroam.tuwien.ac.at"
    ];
  };
}
