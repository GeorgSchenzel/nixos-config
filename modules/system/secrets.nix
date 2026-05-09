{ den, inputs, ... }:

{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    os = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        defaultSopsFile = ../../secrets/example.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

    homeManager = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops = {
        defaultSopsFile = ../../secrets/example.yaml;
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };
  };
}
