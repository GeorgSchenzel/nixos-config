{ den, ... }:

{
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
  };
}
