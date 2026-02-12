{
  inputs,
  ...
}:
{
  flake.modules.nixos.vm-full = {
    imports = with inputs.self.modules.nixos; [ system-cli ]
      ++ [ (inputs.self.factory.disko-btrfs "/dev/vda") ];

    virtualisation.diskSize = 20000;

    users.users.georg = {
      isNormalUser = true;
      description = "Georg";
      extraGroups = [ "wheel" ];
      password = "password";
    };
  };
}
