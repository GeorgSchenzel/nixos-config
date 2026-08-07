require("nvim-hero").setup({})

vim.api.nvim_create_user_command("VimHero", function()
  require("nvim-hero").open_menu()
end, { desc = "Open the nvim-hero lesson menu" })

vim.api.nvim_create_user_command("VimHeroStop", function()
  require("nvim-hero.engine").stop_lesson()
end, { desc = "Stop the current nvim-hero lesson" })
