{ den, ... }:

{
  den.aspects.zellij = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        # zellij sets TERM=zellij-256color inside panes, but its nixpkgs
        # package ships no terminfo. Derive the entry from xterm-256color
        # (the standard workaround), so line editing works inside zellij.
        (pkgs.runCommand "zellij-terminfo" {
          nativeBuildInputs = [ pkgs.ncurses ];
        } ''
          mkdir -p $out/share/terminfo
          infocmp -x xterm-256color | sed 's/xterm-256color/zellij-256color/g' > zellij-256color.ti
          tic -x -o $out/share/terminfo zellij-256color.ti
        '')
      ];
    };

    provides.to-users.homeManager = { pkgs, lib, ... }: {
      programs.zellij = {
        enable = true;
        package = pkgs.runCommand "zellij-wrapped"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
            passthru.version = pkgs.zellij.version;
          }
          ''
            mkdir -p $out/bin
            makeWrapper ${lib.getExe pkgs.zellij} $out/bin/zellij --set ZELLIJ_SOCKET_DIR /tmp/zellij
            # keep completions (and any other share/ data) from the original
            ln -s ${pkgs.zellij}/share $out/share
          '';
      };
    };
  };
}
