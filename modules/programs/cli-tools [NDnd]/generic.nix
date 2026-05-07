let
  genericPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vim
        git
        ffmpeg
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [ genericPackages ];
  };

  flake.modules.darwin.cli-tools = {
    imports = [ genericPackages ];
  };
}
