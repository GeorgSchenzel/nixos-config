{ den, pkgs, ... }: {

    den.aspects.audio = { host, pkgs, ... }: {
        nixos = {
          security.rtkit.enable = true;

          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
          };

          environment.systemPackages = [ pkgs.pavucontrol ];
        };
    };
}
