{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      systemd-boot
      georg
      system-cli
    ];
  };
}
