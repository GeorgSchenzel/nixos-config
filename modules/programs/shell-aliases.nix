{ den, ... }:
{
  den.aspects.shell-aliases = {
    provides.to-users.homeManager = { pkgs, ... }: {
      # generate ~/.bashrc so aliases land there; the generated rc sources
      # hm-session-vars.sh itself, so sessionPath/sessionVariables still apply.
      programs.bash.enable = true;

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
