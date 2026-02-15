{ inputs, ... }:
{
  flake.modules.homeManager.desktop-apps =
    { config, ... }:
    {
      home = inputs.self.lib.mkIfPersistence config {
        persistence."/persist/home".directories = [
          ".mozilla/firefox"
          ".thunderbird"
          ".config/Code"
        ];
      };
    };
}
