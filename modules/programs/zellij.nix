{ den, ... }:

{
  den.aspects.zellij = {
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
          '';
      };
    };
  };
}
