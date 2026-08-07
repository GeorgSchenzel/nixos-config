vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

require("config.options")
require("config.keymaps")

require("plugins.colorscheme")
require("plugins.telescope")
require("plugins.treesitter")
require("plugins.surround")
require("plugins.autopairs")
require("plugins.indent-blankline")
require("plugins.which-key")
