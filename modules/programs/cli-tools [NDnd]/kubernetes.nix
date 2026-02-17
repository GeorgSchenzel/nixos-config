{
  flake.modules.homeManager.cli-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s
    ];
  };
}
