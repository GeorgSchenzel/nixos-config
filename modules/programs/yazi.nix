{ den, lib, ... }:

{
  den.aspects.yazi = {
    provides.to-users.homeManager = { pkgs, ... }: {
      programs.yazi = {
        enable = true;

        # `y` function in zsh/bash: open yazi, and cd the shell to the
        # directory yazi was in when it exits
        enableZshIntegration = true;
        enableBashIntegration = true;

        # Image previews: ghostty speaks the kitty graphics protocol, so
        # previews work there out of the box. Alacritty has no image protocol,
        # but yazi falls back to the Wayland window-system protocol (supported
        # by sway), which needs ueberzugpp on yazi's PATH.
        extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.ueberzugpp
        ];

        settings = {
          opener = {
            # pin the editor to nvim (the wrapped nvim from the neovim aspect)
            # instead of yazi's default '${EDITOR:-vi}'
            edit = [{ run = "nvim %s"; block = true; desc = "nvim"; for = "unix"; }];
          };

          # prepended before yazi's defaults: folders and text/code open in
          # nvim; images/media/unknown keep the defaults (xdg-open / open).
          # `open` runs the first opener of a rule, no picker.
          open.prepend_rules = [
            { mime = "folder/*"; use = [ "edit" "open" "reveal" ]; }
            { mime = "text/*"; use = "edit"; }
            { mime = "application/{json,ndjson,javascript,wine-extension-ini}"; use = "edit"; }
            { mime = "inode/empty"; use = "edit"; }
          ];
        };
      };
    };
  };
}
