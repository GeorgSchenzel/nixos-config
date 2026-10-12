{ den, ... }:

{
  den.aspects.brew = {
    darwin = {
      homebrew.enable = true;
      environment.shellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
  };
}
