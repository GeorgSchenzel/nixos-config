-- nvim-treesitter (main branch): highlight/fold/indent are enabled via
-- Neovim's native treesitter API. Parsers are bundled by Nix.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("nvim-treesitter", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not pcall(vim.treesitter.start, buf) then
      return -- no parser installed for this filetype
    end
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldlevel = 99
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
