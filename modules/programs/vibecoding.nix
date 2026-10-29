{ den, inputs, ... }:

{
  flake-file.inputs.forest.url = "git+ssh://git@github.com/GeorgSchenzel/forest";

  den.aspects.vibecoding = {
    os = {
      # forest (worktree manager) shell integration; prefers forest on PATH,
      # falls back to a cargo build
      programs.zsh = {
        enable = true;
        interactiveShellInit = ''
          () {
            local bin=''${commands[forest]:-$HOME/.cargo/bin/forest}
            [[ -x $bin ]] && eval "$($bin shell-init zsh)"
          }
        '';
      };
    };

    provides.to-users.homeManager = { pkgs, ... }: {
      home.packages = [
        inputs.forest.packages.${pkgs.stdenv.hostPlatform.system}.default
        # $HOME expands at runtime: nix only splices the literal into the script.
        (pkgs.writeShellScriptBin "forest-dev" ''
          exec "$HOME/.cargo/bin/forest" "$@"
        '')
      ];
    };

    persist-home = {
      # forest's root (FOREST_ROOT default): project clones and workforests
      directories = [ "projects" ];
    };
  };
}
