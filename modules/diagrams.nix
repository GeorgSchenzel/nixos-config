{ config, den, lib, ... }:
let
  diag = den.lib.diag;
in
{
  perSystem = { pkgs, system, ... }:
    let
      rc = diag.renderContext { inherit pkgs; };
      systemHosts = config.den.hosts.${system} or { };
    in
    {
      packages = lib.mapAttrs' (hostName: host:
        lib.nameValuePair "diag-${hostName}" (
          rc.mmdSourceToSvg hostName (rc.render.toMermaid (diag.hostContext { inherit host; }))
        )
      ) systemHosts;
    };
}
