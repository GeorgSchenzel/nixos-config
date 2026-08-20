vim.g.loaded_netrwPlugin = 1

require("yazi").setup({
  open_for_directories = true,
})

vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Yazi at current file" })
vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<cr>", { desc = "Yazi at cwd" })
