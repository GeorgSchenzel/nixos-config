{ den, inputs, ... }:

{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        defaultSopsFile = ../../secrets/example.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

    darwin = {
      imports = [ inputs.sops-nix.darwinModules.sops ];
      sops = {
        defaultSopsFile = ../../secrets/example.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };


    provides.to-users.homeManager = { config, pkgs, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      home.packages = [ pkgs.sops ];
      # .sops.yaml lists ssh-to-age converted recipients; sops would treat
      # ~/.ssh/id_ed25519 as an ssh identity (no match), and on darwin it looks
      # for keys.txt under ~/Library. Derive the age key from the ssh key instead.
      home.sessionVariables.SOPS_AGE_KEY_CMD =
        "${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${config.home.homeDirectory}/.ssh/id_ed25519";
      sops = {
        defaultSopsFile = ../../secrets/example.yaml;
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };
  };
}
