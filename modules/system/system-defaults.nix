{ den, ... }:
{
    den.aspects.system-defaults = {
        nixos = {
            console.keyMap = "de";
            environment.localBinInPath = true;
        };
    };
}
