{ den, inputs, lib, ... }:

{
  perSystem = { pkgs, system, ... }: {
    packages.msb = lib.mkIf (system == "x86_64-linux") (pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "msb";
      version = "0.6.11";

      src = pkgs.fetchurl {
        url = "https://github.com/superradcompany/microsandbox/releases/download/v${finalAttrs.version}/microsandbox-linux-x86_64.tar.gz";
        hash = "sha256-g0edPLQL+8fFcx5kQbY9CPCOLmecZxb8J7fx/+FVH3E=";
      };

      sourceRoot = ".";

      nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
      buildInputs = with pkgs; [
        libcap_ng
        libgcc
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 msb $out/bin/msb
        ln -s msb $out/bin/microsandbox

        libfile=(libkrunfw.so.*.*.*)
        install -Dm644 "''${libfile[0]}" "$out/lib/''${libfile[0]}"
        major="''${libfile[0]#libkrunfw.so.}"
        major="''${major%%.*}"
        ln -s "''${libfile[0]}" "$out/lib/libkrunfw.so.$major"

        runHook postInstall
      '';

      meta = {
        description = "Easy, fast microVMs for untrusted workloads, on your machine or in the cloud";
        homepage = "https://github.com/superradcompany/microsandbox";
        changelog = "https://github.com/superradcompany/microsandbox/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.asl20;
        mainProgram = "msb";
        platforms = [ "x86_64-linux" ];
      };
    }));
  };

  den.aspects.microsandbox = {
    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = lib.optionals (pkgs.system == "x86_64-linux") [
          inputs.self.packages.${pkgs.system}.msb
        ];
      };

    persist-home = {
      directories = [ ".microsandbox" ];
    };
  };
}
