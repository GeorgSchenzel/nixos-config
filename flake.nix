{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, disko, ...} @ inputs:
  {
    nixosConfigurations = {
      nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
          ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })

          ./hosts/nixos-test

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.georg = import ./home;
          }
        ];
      };

      lab-garden = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
          #({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
          ./hosts/lab-garden
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
  };
}
