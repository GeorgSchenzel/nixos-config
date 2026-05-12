{ den, inputs, ... }: {

    den.aspects.desktop = { host, ... }: {
        nixos = {
            boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
            boot.initrd.kernelModules = [ ];
            boot.kernelModules = [ "kvm-amd" ];
            boot.extraModulePackages = [ ];

            nixpkgs.hostPlatform = "x86_64-linux";
            hardware.cpu.amd.updateMicrocode = true;
        };
    };
}
