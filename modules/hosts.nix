# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # georg user at desktop host.
  den.hosts.x86_64-linux.desktop.users.georg = { };

  # define an standalone home-manager for georg
  # den.homes.x86_64-linux.georg = { };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.alice = { };

  # other hosts can also have user tux.
  # den.hosts.x86_64-linux.south = {
  #   wsl = { }; # add nixos-wsl input for this.
  #   users.tux = { };
  #   users.orca = { };
  # };
}
