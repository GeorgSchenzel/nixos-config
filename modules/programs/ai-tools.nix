{ den, inputs, ... }:

{
  flake-file.inputs.opencode.url = "github:anomalyco/opencode/f06b78751e08ca38dc50da7f7ca1c408e6ad6298";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, ... }:
    let
      opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = [ opencode ];

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
