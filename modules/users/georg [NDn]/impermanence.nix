{ inputs, ... }:
{
  flake.modules.homeManager.georg =
    { config, ... }:
    {
      home = inputs.self.lib.mkIfPersistence config {
        persistence."/persist".directories = [
          ".ssh"
        ];
      };
    };
}
