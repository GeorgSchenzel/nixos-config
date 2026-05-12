# enables `nix run .#vm`. it is very useful to have a VM
# you can edit your config and launch the VM to test stuff
# instead of having to reboot each time.
{ inputs, den, lib, ... }:
{
  den.aspects.vm = { host, ... }: {
        nixos = {
            virtualisation.vmVariantWithDisko = {
              disko.devices.disk.main.device = lib.mkForce "/dev/vda";
              virtualisation.forwardPorts = [
                  { from = "host"; host.port = 2222; guest.port = 22; }
              ];
              security.sudo.wheelNeedsPassword = false;
              
            virtualisation.fileSystems."/home".neededForBoot = true;
            virtualisation.fileSystems."/persist/home".neededForBoot = true;
            virtualisation.fileSystems."/persist/system".neededForBoot = true;
            virtualisation.fileSystems."/persist/server".neededForBoot = true;
            };
        };
    };
}
