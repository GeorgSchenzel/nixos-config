{ den, inputs, ... }:

{
  flake-file.inputs.workmux.url = "github:raine/workmux";
  flake-file.inputs.herdr.url = "github:herdrdev/herdr/v0.8.0";
  flake-file.inputs.bento.url = "git+ssh://git@github.com/GeorgSchenzel/bento";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }:
    {
      home.packages = [
        pkgs.lima
        pkgs.claude-code
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        inputs.bento.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # Keep ~/.claude.json inside ~/.claude so a single persisted directory
      # covers auth, history and settings. Claude rewrites .claude.json via
      # atomic rename, which breaks on a bind-mounted single file.
      home.sessionVariables.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.claude";

      programs.opencode = {
        enable = true;
        settings = {
          model = "zai-coding-plan/glm-5.3";
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
        "bento/claude-token" = {
          path = "${config.home.homeDirectory}/.config/bento/claude-token";
        };
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
        ".claude"
      ];
    };
  };
}
