{
  inputs,
  ...
}:

{
  flake.modules.homeManager.ai-tools = { config, pkgs, ... }:
  let
    opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in
  {
    home.packages = [ opencode ];

    sops.secrets = {
      zai-api-key = {};
      aqueduct-api-key = {};
    };

    sops.templates."opencode-auth.json" = {
      path = "${config.home.homeDirectory}/.local/share/opencode/auth.json";
      content = builtins.toJSON {
        zai-coding-plan = {
          type = "api";
          key = config.sops.placeholder.zai-api-key;
        };
        aqueduct = {
          type = "api";
          key = config.sops.placeholder.aqueduct-api-key;
        };
      };
    };
  };
}
