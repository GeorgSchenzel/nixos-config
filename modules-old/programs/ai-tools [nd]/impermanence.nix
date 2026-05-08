{ inputs, ... }:
{
  flake.modules.homeManager.ai-tools =
    { config, ... }:
    {
      home = inputs.self.lib.mkIfPersistence config {
        persistence."/persist/home".directories = [
          ".local/share/opencode"
          ".local/state/opencode"
        ];
      };
    };
}
