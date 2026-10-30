{ den, inputs, ... }:

{
  flake-file.inputs.bento.url = "git+ssh://git@github.com/GeorgSchenzel/bento";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }:
    {
      home.packages = [
        pkgs.lima
        pkgs.claude-code
        (pkgs.writeShellScriptBin "claude2" ''
          export CLAUDE_CONFIG_DIR="$HOME/.claude-2"
          exec "${lib.getExe pkgs.claude-code}" "$@"
        '')
      ] ++ (let
        bento = inputs.bento.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # bento reads ~/.config/bento/claude-token itself; BENTO_CLAUDE_TOKEN
        # takes precedence, so the second account only needs the env override.
        # bento sets CLAUDE_CONFIG_DIR per box, so the host one doesn't matter.
        bento2 = pkgs.writeShellScriptBin "bento2" ''
          f="${config.sops.secrets."bento/claude-token-2".path}"
          if [ -f "$f" ]; then
            export BENTO_CLAUDE_TOKEN="$(<"$f")"
          else
            echo "bento2: token missing at $f (sops not activated?)" >&2
          fi
          exec "${lib.getExe bento}" "$@"
        '';
      in [
        bento
        bento2
        # $HOME expands at runtime: nix only splices the literal into the script.
        (pkgs.writeShellScriptBin "bento-dev" ''
          exec "$HOME/.cargo/bin/bento" "$@"
        '')
      ]);

      # Keep ~/.claude.json inside ~/.claude so a single persisted directory
      # covers auth, history and settings. Claude rewrites .claude.json via
      # atomic rename, which breaks on a bind-mounted single file.
      home.sessionVariables.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.claude";

      # Share prompt history and session transcripts between both accounts.
      # Auth (.claude.json), settings and live session state stay per-account.
      # paste-cache holds pasted text referenced from history.jsonl.
      home.file = lib.genAttrs
        (map (name: ".claude-2/${name}") [ "history.jsonl" "projects" "file-history" "paste-cache" "plans" ])
        (path: {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/.claude/${lib.removePrefix ".claude-2/" path}";
        });

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
        "bento/claude-token-2" = { };
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
        ".claude-2"
        ".local/share/bento"
      ];
    };
  };
}
