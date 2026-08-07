require("which-key").setup({
  expand = 2, -- auto-expand groups with <= 2 mappings inline
})

require("which-key").add({
  { "<leader>f", group = "Telescope" },
})
