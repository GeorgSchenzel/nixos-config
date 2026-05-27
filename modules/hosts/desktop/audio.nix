{ den, ... }: {

    den.aspects.desktop = { host, ... }: {
        nixos = { pkgs, ... }: {
            services.pipewire.wireplumber.configPackages = [
                (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-audio-rules.conf" ''
                    monitor.alsa.rules = [
                    {
                        matches = [
                        {
                            node.name = "alsa_output.pci-0000_0a_00.4.analog-stereo"
                        }
                        ]
                        actions = {
                        update-props = {
                            priority.driver = 2000
                            priority.session = 2000
                            session.suspend-timeout-seconds = 0
                        }
                        }
                    }
                    {
                        matches = [
                        {
                            node.name = "alsa_input.usb-3142_fifine_Microphone-00.analog-stereo"
                        }
                        ]
                        actions = {
                        update-props = {
                            priority.driver = 2000
                            priority.session = 2000
                        }
                        }
                    }
                    {
                        matches = [
                        {
                            node.name = "alsa_output.usb-3142_fifine_Microphone-00.analog-stereo"
                        }
                        ]
                        actions = {
                        update-props = {
                            node.disabled = true
                        }
                        }
                    }
                    {
                        matches = [
                        {
                            node.name = "alsa_input.pci-0000_0a_00.4.analog-stereo"
                        }
                        ]
                        actions = {
                        update-props = {
                            node.disabled = true
                        }
                        }
                    }
                    {
                        matches = [
                        {
                            node.name = "alsa_output.pci-0000_08_00.1.hdmi-stereo"
                        }
                        ]
                        actions = {
                        update-props = {
                            node.disabled = true
                        }
                        }
                    }
                    {
                        matches = [
                        {
                            device.name = "alsa_card.usb-Microsoft_Microsoft___LifeCam_HD-3000-02"
                        }
                        ]
                        actions = {
                        update-props = {
                            device.disabled = true
                        }
                        }
                    }
                    ]
                '')
                ];
        };
    };
}
