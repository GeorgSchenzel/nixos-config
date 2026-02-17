{ inputs, ... }:
{
  flake.modules.darwin.mbp = {
    imports = with inputs.self.modules.darwin; [
      system-desktop
      georg
      yabai
    ];
  };
}
