-- blink.cmp: completion / intellisense. Built-in sources (lsp/path/buffer/snippets).
-- Flag set so plugins.lsp can pull augmented capabilities; load this before plugins.lsp.
vim.g.blink_loaded = true

require("blink-cmp").setup({
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
    menu = { border = "rounded" },
  },
  signature = { enabled = true, window = { border = "rounded" } },
})
