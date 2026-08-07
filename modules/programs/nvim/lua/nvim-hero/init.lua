local nvim_hero = {}

function nvim_hero.setup(opts)
  require("nvim-hero.config").setup(opts)
  require("nvim-hero.highlight").define_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("nvim-hero", { clear = true }),
    callback = function() require("nvim-hero.highlight").define_highlights() end,
  })
end

function nvim_hero.open_menu()
  require("nvim-hero.ui.menu").open()
end

return nvim_hero
