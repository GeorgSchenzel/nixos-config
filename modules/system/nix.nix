{ den, inputs, ... }:
{
    den.aspects.nix = {
        os = { pkgs, ... }: {

            nixpkgs.config.allowUnfree = true;

            nix.settings = {
                substituters = [
                "https://cache.nixos.org?priority=10"
                "https://nix-community.cachix.org"
                ];

                trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                ];

                experimental-features = [
                "nix-command"
                "flakes"
                ];

                download-buffer-size = 1024 * 1024 * 1024;

                trusted-users = [
                "root"
                "@wheel"
                ];
            };
        };

        nixos = { pkgs, ... }: {

            system.stateVersion = "25.11";

            programs.nix-ld.enable = true;

            nix.extraOptions = ''
                warn-dirty = false
                keep-outputs = true
            '';
        };

        darwin = { pkgs, ... }: {
            system.stateVersion = 6;

            nix.settings.trusted-users = [
              "root"
              "@admin"
            ];

            nix.linux-builder = {
              enable = true;
              maxJobs = 4;
              config.virtualisation = {
                cores = 4;
                darwin-builder.memorySize = 6 * 1024;
                darwin-builder.diskSize = 40 * 1024;
              };
            };
        };
    };
}