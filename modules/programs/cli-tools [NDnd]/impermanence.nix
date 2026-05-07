{ inputs, ... }:
{
  flake.modules.homeManager.cli-tools =
    { config, ... }:
    {
      home = inputs.self.lib.mkIfPersistence config {
        persistence."/persist/home".files = [
          ".bash_history"
        ];
      };
    };
}
