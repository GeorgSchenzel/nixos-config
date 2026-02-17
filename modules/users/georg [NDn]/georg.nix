{ self, ... }:

let
  commonUserConfig = {
    description = "Georg";
  };

  commonConfig = {
    home-manager.users.georg = {
      imports = [
        self.modules.homeManager.georg
      ];
    };
  };
in
{
  flake.modules.nixos.georg = { ... }: commonConfig // {
    users.users.georg = commonUserConfig // {
      isNormalUser = true;
      home = "/home/georg";
      extraGroups = [ "wheel" ];
      createHome = true;
      password = "password";
    };
  };

  flake.modules.darwin.georg = { ... }: commonConfig // {
    users.users.georg = commonUserConfig // {
      home = "/Users/georg";
    };
    system.primaryUser = "georg";
  };

  flake.modules.homeManager.georg = { pkgs, ... }: {
    home.username = "georg";
    home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/georg" else "/home/georg";
  };
}
