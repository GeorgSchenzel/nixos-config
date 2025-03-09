{
  pkgs,
  lib,
  ...
}: 
let
  username = "georg";
in 
{
  # ============================= User related =============================

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.georg = {
    isNormalUser = true;
    description = "georg";
    password = "123456";
    initialPassword  = "123456";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV6aIIziZjqSeC3EZpW711edxHm/pSCQ/bZEmdbxyHHuM90SgUQA7EOUzXeTdQYhD1FIGp/p0T2U/xbGehFM1YeW/7H+F3+Yug2OrCbV2ZxH14f1e4keYd1IMqJLBxUehY+kvmc5Y3tY4ZxLGkC0fiffRJPdIuiyfZsbnzBoVzqp8AyEClfTCzXNbXCSSg983Y1kIL2R4G6Lc6r445HjsOF6qFHV6tb4IGuaP4t5Dd3p6uERF2Rm3tgsaFgjsXRBXkZp406Y1abTuImTNpSVD0oTAju7XcBI3iASDdqLlLTlVYVfCIrmG3POZ6R2jShkj/CqKPWiWpYZzdgs1MhXPTOFbIAFYrMJM9+MXKzv0r8vYIBe7x+OEuXQzzafbZFGfiNwlLq/rxhxKFVxxJcJWnAplRNMp1od8wa46e/yLu9Pr0Y5Om4EcqjWHDJzg++/4cQ85w50gSkx8bVMSVTuRMEBpXOhhXWUEgxF6dJkoIhNWXgtRXP/5rhE7rqP43ZCc= georg@desktop"
    ];
  };
  nix.settings.trusted-users = [username];

  nix.settings = {
    # enable flakes
    experimental-features = ["nix-command" "flakes"];
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 30d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";
  services.xserver.xkb.layout = "de";
  services.xserver.layout = "de";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
    ];

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  security.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    sysstat
    lm_sensors # for `sensors` command
    neofetch
    ranger
    vscode
    firefox
  ];
}
