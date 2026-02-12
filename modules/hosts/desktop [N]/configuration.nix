{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [ system-cli ]
      ++ [ (inputs.self.factory.disko-btrfs "/dev/nvme0n1") ];

    users.users.georg = {
      isNormalUser = true;
      description = "Georg";
      extraGroups = [ "wheel" ];
      password = "password";
    };
  };
}
