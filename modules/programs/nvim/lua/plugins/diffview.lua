require("diffview").setup({
  use_icons = false,
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diffview: changed files" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<CR>", { desc = "Diffview: close" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview: file history" })
