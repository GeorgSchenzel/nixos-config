{ den, ... }: {
  den.hosts.x86_64-linux.homelab.mainDiskDevice = "/dev/TODO";
  den.hosts.x86_64-linux.homelab.btrfsPartition = "/dev/TODO";

  den.aspects.homelab = {
    includes = [
      den.aspects.bootloader
      den.aspects.disko
      den.aspects.nix
      den.aspects.system-defaults
      den.aspects.homeManager
      den.aspects.secrets
      den.aspects.impermanence
      den.aspects.ssh
      den.aspects.firmware
      den.aspects.vm
      den.aspects.cli-tools
      den.aspects.podman
      den.aspects.neovim
      den.aspects.zellij
    ];

    nixos = { pkgs, ... }: {
      # xterm-ghostty & co: ssh clients carry their $TERM over, so the
      # server needs matching terminfo entries for sane line editing
      environment.enableAllTerminfo = true;
    };

    provides.to-users.homeManager = { pkgs, ... }: {
    };
  };
}
