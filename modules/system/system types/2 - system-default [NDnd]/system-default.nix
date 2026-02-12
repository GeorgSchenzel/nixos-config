{
  inputs,
  ...
}:
{
  # Import essential nix-tools used in all modules of a specific class

  flake.modules.nixos.system-default = {
    imports =
      with inputs.self.modules.nixos;
      [
        system-minimal
        home-manager
      ]
      ++ (with inputs.self.modules.generic; [
        systemConstants
        pkgs-by-name
      ]);

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-default
    ];

    console.keyMap = "de";
  };

  flake.modules.darwin.system-default = {
    imports =
      with inputs.self.modules.darwin;
      [
        system-minimal
        home-manager
      ]
      ++ (with inputs.self.modules.generic; [
        systemConstants
        pkgs-by-name
      ]);

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.system-default
    ];

    console.keyMap = "de";
  };

  flake.modules.homeManager.system-default = {
    imports =
      with inputs.self.modules.homeManager;
      [
        system-minimal
      ]
      ++ [ inputs.self.modules.generic.systemConstants ];
  };
}
