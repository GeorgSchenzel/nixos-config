{ den, ... }:
{
  den.aspects.photography = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      # rapidraw: GPU-accelerated non-destructive RAW editor (Tauri app).
      # Guarded so the aspect is safe to include on darwin later (no-op there).
      home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.rapidraw ];
    };

    # Tauri app_data_dir: settings.json (export presets, custom lenses,
    # workspace layout). Rewritten by the app itself, so persisted not
    # nix-managed. Host home is rolled back on boot, so this is required.
    persist-home = {
      directories = [
        ".local/share/io.github.CyberTimon.RapidRAW"
      ];
    };
  };
}
