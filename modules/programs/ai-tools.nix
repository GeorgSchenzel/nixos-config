{ den, inputs, ... }:

{
  flake-file.inputs.workmux.url = "github:raine/workmux";
  flake-file.inputs.herdr.url = "github:herdrdev/herdr/v0.8.0";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, ... }:
    let
      workmux = inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
      herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = [ pkgs.lima workmux herdr ];

      programs.opencode = {
        enable = true;
        settings = {
          model = "zai-coding-plan/glm-5.2";
          permission = {
            "*" = "allow";
            doom_loop = "ask";
            external_directory."*" = "ask";
            read = {
              "*" = "allow";
              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";
            };
          };
        };
      };

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
        ".config/herdr"
        ".herdr"
      ];
    };
  };
}
