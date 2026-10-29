{ den, ... }:
{
  # included by user aspects; the plain homeManager class reaches the user
  # on every host (provides.to-users is host-aspect semantics and would be dropped).
  den.aspects.shell-aliases = {
    homeManager = { pkgs, ... }: {
      # generate ~/.bashrc and ~/.zshrc so aliases land there; the generated
      # rcs source hm-session-vars.sh themselves, so sessionPath/sessionVariables
      # still apply in both shells.
      programs.bash.enable = true;
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      };

      # home.shellAliases (not programs.bash.shellAliases) so a future
      # zsh/fish switch picks these up automatically.
      home.shellAliases = {
        # nh has no os-agnostic subcommand; configs evaluate per-platform,
        # so pick darwin/os at build time.
        nrs = "nh ${if pkgs.stdenv.isDarwin then "darwin" else "os"} switch";
        nru = "nh ${if pkgs.stdenv.isDarwin then "darwin" else "os"} switch --update";
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
