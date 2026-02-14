{ inputs, ... }:
{
  flake.modules.nixos.ssh = { config, ... }: {
    environment = inputs.self.lib.mkIfPersistence config {
      persistence."/persist".files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}