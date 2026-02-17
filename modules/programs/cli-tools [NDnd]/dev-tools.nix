{
  flake.modules.homeManager.cli-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs
      bun
      uv
      just
    ];
  };
}
