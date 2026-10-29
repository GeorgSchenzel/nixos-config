{ den, ... }:

{
  den.aspects.vibecoding = {
    os = {
      # forest (worktree manager) shell integration; PATH order puts ~/.cargo/bin first
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
