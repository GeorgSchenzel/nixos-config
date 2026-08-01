{ den, inputs, ... }:

{
  flake-file.inputs.opencode.url = "github:anomalyco/opencode";
  flake-file.inputs.workmux.url = "github:raine/workmux";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, ... }:
    let
      opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
      workmux = inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = [ opencode pkgs.lima workmux ];

      sops.secrets = {
        zai-api-key = { };
        aqueduct-api-key = { };
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

    persist-home = {
      directories = [
        ".local/share/opencode"
        ".local/state/opencode"
      ];
    };
  };
}
