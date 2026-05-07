{ inputs, ... }:
{
  flake.modules.darwin.mbp = {
    imports = with inputs.self.modules.darwin; [
      system-cli
      system-desktop
      georg
      yabai
    ];
  };
}
