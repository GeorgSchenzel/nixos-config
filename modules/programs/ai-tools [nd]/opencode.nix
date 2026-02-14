{
  inputs,
  ...
}:

{
  flake.modules.homeManager.opencode = { config, pkgs, ... }:
  let
    opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in
  {
    home.packages = [ opencode ];

    sops.secrets.zai-api-key = {};

    sops.templates."opencode-auth.json" = {
      path = "${config.home.homeDirectory}/.local/share/opencode/auth.json";
      content = builtins.toJSON {
        zai-coding-plan = {
          type = "api";
          key = config.sops.placeholder.zai-api-key;
        };
      };
    };
  };
}
