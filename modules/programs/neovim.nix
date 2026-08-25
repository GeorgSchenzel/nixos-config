{ den, inputs, ... }:

{
  flake-file.inputs.nix-wrapper-modules = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.neovim = {
    os = { pkgs, ... }: {
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

    provides.to-users.homeManager = { lib, pkgs, ... }:
      let
        wrappedNvim = inputs.nix-wrapper-modules.wrappers.neovim.wrap {
          inherit pkgs;
          settings.config_directory = ./nvim;
          # settings.config_directory = "/home/georg/nixos-config/modules/programs/nvim"; # dev: live edits, no rebuild
          settings.aliases = [ "vi" "vim" ];
          specs = with pkgs.vimPlugins; {
            tokyonight       = tokyonight-nvim;
            telescope        = telescope-nvim;
            treesitter       = nvim-treesitter.withPlugins (p: [
              p.nix p.lua p.bash p.vim p.vimdoc p.query
              p.python p.rust p.go p.c p.cpp p.java p.c_sharp
              p.typescript p.tsx p.javascript
              p.json p.yaml p.toml p.markdown p.markdown_inline p.regex p.css
            ]);
            surround         = nvim-surround;
            autopairs        = nvim-autopairs;
            indent-blankline = indent-blankline-nvim;
            which-key        = which-key-nvim;
            lspconfig        = nvim-lspconfig;
            blink            = blink-cmp;
            friendly-snippets = friendly-snippets;
            gitsigns         = gitsigns-nvim;
            yazi             = yazi-nvim;
          };
          runtimePkgs = with pkgs; [
            ripgrep fd yazi lazygit
            nil lua-language-server gopls basedpyright rust-analyzer
            typescript-language-server bash-language-server
            jdt-language-server
          ] ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ csharp-ls ];
        };
      in
      {
        home.packages = [ wrappedNvim ];
      };

    persist-home = {
      directories = [ ".local/state/nvim" ".local/state/yazi" ];
    };
  };
}
