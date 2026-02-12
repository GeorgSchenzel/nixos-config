{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      georg
      system-cli
    ];
  };
}
