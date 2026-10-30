{ den, ... }:
{
  # included by user aspects; the plain homeManager class reaches the user
  # on every host (provides.to-users is host-aspect semantics and would be dropped).
  den.aspects.shell-aliases = {
    homeManager = { config, lib, pkgs, ... }: {
      # generate ~/.bashrc and ~/.zshrc so aliases land there; the generated
      # rcs source hm-session-vars.sh themselves, so sessionPath/sessionVariables
      # still apply in both shells.
      programs.bash.enable = true;
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        # in a directory so it can be persisted: zsh saves history by
        # rename, which fails on a bind-mounted single file
        history.path = "${config.xdg.dataHome}/zsh/history";

        # call a ~/.cargo/bin build that is shadowed by a nix-profile one
        initContent = lib.mkAfter ''
          dev() {
            [ $# -gt 0 ] || { echo "usage: dev <tool> [args...]" >&2; return 2; }
            local b="$HOME/.cargo/bin/$1"
            shift
            [ -x "$b" ] || { echo "no cargo build: $b" >&2; return 1; }
            "$b" "$@"
          }
        '';
      };

      # User-installed tool dirs, appended so nix-profile wins name clashes.
      # Goes into hm-session-vars.sh, which both bash and zsh source once per
      # session (also non-interactive), so no duplicate PATH entries.
      home.sessionVariablesExtra = ''
        export PATH="$PATH:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.unity/bin"
      '';

      # home.shellAliases (not programs.bash.shellAliases) so a future
      # zsh/fish switch picks these up automatically.
      home.shellAliases = {
        # nh has no os-agnostic subcommand; configs evaluate per-platform,
        # so pick darwin/os at build time.
        nrs = "nh ${if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "os"} switch";
        nru = "nh ${if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "os"} switch --update";
        ngc = "nh clean all";

        # navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # ls
        ll = "ls -lah";
        la = "ls -lAh";

        # safety / colors
        grep = "grep --color=auto";
        mkdir = "mkdir -p";
        cp = "cp -i";
        mv = "mv -i";
      };
    };
  };
}
