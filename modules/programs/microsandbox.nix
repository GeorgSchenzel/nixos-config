{ den, inputs, lib, ... }:

{
  perSystem = { pkgs, system, ... }: {
    packages.msb = lib.mkIf (system == "x86_64-linux" || system == "aarch64-darwin") (pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "msb";
      version = "0.6.11";

      src = pkgs.fetchurl (
        if system == "aarch64-darwin" then {
          url = "https://github.com/superradcompany/microsandbox/releases/download/v${finalAttrs.version}/microsandbox-darwin-aarch64.tar.gz";
          hash = "sha256-C48A4C2eNM3SmpMku+RvYmXS2TlzABE9XKKfrFMvAYg=";
        } else {
          url = "https://github.com/superradcompany/microsandbox/releases/download/v${finalAttrs.version}/microsandbox-linux-x86_64.tar.gz";
          hash = "sha256-g0edPLQL+8fFcx5kQbY9CPCOLmecZxb8J7fx/+FVH3E=";
        }
      );

      sourceRoot = ".";

      nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.makeBinaryWrapper ];
      buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.libcap_ng
        pkgs.libgcc
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 msb $out/bin/msb
        ln -s msb $out/bin/microsandbox

        if dylib=(libkrunfw.*.dylib) && [ -f "''${dylib[0]}" ]; then
          install -Dm644 "''${dylib[0]}" "$out/lib/''${dylib[0]}"
          ln -s "''${dylib[0]}" "$out/lib/libkrunfw.dylib"
        else
          libfile=(libkrunfw.so.*.*.*)
          install -Dm644 "''${libfile[0]}" "$out/lib/''${libfile[0]}"
          major="''${libfile[0]#libkrunfw.so.}"
          major="''${major%%.*}"
          ln -s "''${libfile[0]}" "$out/lib/libkrunfw.so.$major"
        fi

        runHook postInstall
      '';

      postInstall = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        mv $out/bin/msb $out/bin/.msb-unwrapped
        dylib=("$out"/lib/libkrunfw.*.dylib)
        makeBinaryWrapper $out/bin/.msb-unwrapped $out/bin/msb \
          --set MSB_LIBKRUNFW_PATH "''${dylib[0]}"
      '';

      meta = {
        description = "Easy, fast microVMs for untrusted workloads, on your machine or in the cloud";
        homepage = "https://github.com/superradcompany/microsandbox";
        changelog = "https://github.com/superradcompany/microsandbox/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.asl20;
        mainProgram = "msb";
        platforms = [ "x86_64-linux" "aarch64-darwin" ];
      };
    }));
  };

  den.aspects.microsandbox = {
    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = let system = pkgs.stdenv.hostPlatform.system; in
          lib.optionals (system == "x86_64-linux" || system == "aarch64-darwin") [
            inputs.self.packages.${system}.msb
          ];
      };

    persist-home = {
      directories = [ ".microsandbox" ];
    };
  };
}
