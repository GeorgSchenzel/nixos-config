{ den, inputs, ... }:

{
  flake-file.inputs.bento.url = "git+ssh://git@github.com/GeorgSchenzel/bento";

  den.aspects.ai-tools = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }:
    {
      # bento via its home-manager module: puts bento on PATH and lets
      # stew's services.stew pick the package up for its units (extraPackages).
      # The wok channel points boxes at the GPU job daemon (wok aspect);
      # git hosts get the token files from the vault; claude reads its
      # token from the default sops path, opencode the shared auth.json.
      imports = [ inputs.bento.homeManagerModules.bento ];

      programs.bento = {
        enable = true;
        settings.channels.wok.socket = "~/.local/share/wok/wok.sock";
        # box tools follow the flake inputs, so `nix flake update` updates them
        settings.tools.wok = "github:GeorgSchenzel/wok/${inputs.wok.rev}#wok";
        git = {
          "github.com" = config.sops.secrets."git/github-com".path;
          "gitlab.com" = config.sops.secrets."git/gitlab-com".path;
        };
        agents.claude = {
          enable = true;
          tokenFile = config.sops.secrets."bento/claude-token".path;
          tool = "github:NixOS/nixpkgs/${inputs.nixpkgs.rev}#claude-code";
        };
        agents.opencode.enable = true; # authFile defaults to ~/.local/share/opencode/auth.json
        agents.opencode.tool = "github:NixOS/nixpkgs/${inputs.nixpkgs.rev}#opencode";
      };

      home.packages = [
        pkgs.lima
        pkgs.claude-code
        (pkgs.writeShellScriptBin "claude2" ''
          export CLAUDE_CONFIG_DIR="$HOME/.claude-2"
          exec "${lib.getExe pkgs.claude-code}" "$@"
        '')
      ] ++ [
        # the second account's claude token, via bento core's -e passthrough:
        # bento claude/opencode let CLAUDE_CODE_OAUTH_TOKEN beat tokenFile.
        # bento2 exec <box> -- claude doesn't pass it on its own — use
        # `bento2 exec <box> -e CLAUDE_CODE_OAUTH_TOKEN -- claude`. A missing
        # token exits 125 instead of falling back to the first account.
        (pkgs.writeShellScriptBin "bento2" ''
          f="${config.sops.secrets."bento/claude-token-2".path}"
          if [ ! -r "$f" ]; then
            echo "bento2: token missing at $f (sops not activated?)" >&2
            exit 125
          fi
          export CLAUDE_CODE_OAUTH_TOKEN="$(<"$f")"
          exec "${lib.getExe config.programs.bento.package}" "$@"
        '')
        # $HOME expands at runtime: nix only splices the literal into the script.
        (pkgs.writeShellScriptBin "bento-dev" ''
          exec "$HOME/.cargo/bin/bento" "$@"
        '')
      ];

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
        # default sops path: programs.bento's agents.claude.tokenFile reads it
        "bento/claude-token" = { };
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
