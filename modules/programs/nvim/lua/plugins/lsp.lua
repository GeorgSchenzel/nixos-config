-- nvim-lspconfig via the Neovim 0.11+ vim.lsp API (:help lspconfig-nvim-0.11).
-- Language servers are provided by Nix in runtimePkgs; we just configure/enable.

-- blink.cmp augments LSP capabilities (plugins.blink loads before this).
local capabilities = (vim.g.blink_loaded and require("blink-cmp").get_lsp_capabilities())
  or vim.lsp.protocol.make_client_capabilities()

-- Defaults for every server.
vim.lsp.config("*", { capabilities = capabilities })

-- Diagnostics UI. (]d / [d / <C-w>d navigation are built-in.)
vim.diagnostic.config({
  virtual_text = { prefix = "·", spacing = 2 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})
vim.keymap.set("n", "<leader>lx", vim.diagnostic.open_float, { desc = "LSP: line diagnostics" })

-- Buffer keymaps on attach. (Built-ins cover K, gra, gri, grn, grr, grO, CTRL-S,
-- tagfunc/omnifunc/formatexpr; we add definition jumps + telescope symbol pickers.)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user.lsp", { clear = true }),
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    local tb = require("telescope.builtin")
    map("gd", vim.lsp.buf.definition, "go to definition")
    map("gD", vim.lsp.buf.declaration, "go to declaration")
    map("<leader>la", vim.lsp.buf.code_action, "code action")
    map("<leader>lr", vim.lsp.buf.rename, "rename symbol")
    map("<leader>lR", tb.lsp_references, "references")
    map("<leader>ld", tb.lsp_document_symbols, "document symbols")
    map("<leader>lw", tb.lsp_workspace_symbols, "workspace symbols")
  end,
})

-- Per-server overrides (lspconfig defaults are merged automatically).
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
    },
  },
})

-- TODO (follow-up): rust_analyzer needs a Rust toolchain in runtimePkgs
-- (cargo + rustc + rust-src in sysroot). Options: rust-overlay (recommended),
-- nixpkgs native, or rely on devenv/direnv per project. Add rust-analyzer
-- settings (procMacro, buildScripts, clippy check).

-- TODO (follow-up): consider upgrading jdtls to nvim-lspconfig's jdtls.setup()
-- with a per-workspace data dir under persisted ~/.local/state/nvim.

-- Enable servers (auto-attach on matching filetypes).
-- csharp-ls is only added to runtimePkgs on non-darwin (crashes on aarch64-darwin, nixpkgs badPlatforms).
local servers = {
  "nil_ls", "gopls", "basedpyright", "rust_analyzer", "ts_ls",
  "bashls", "jdtls", "lua_ls",
}
if vim.fn.executable("csharp-ls") == 1 then
  table.insert(servers, "csharp_ls")
end
vim.lsp.enable(servers)
