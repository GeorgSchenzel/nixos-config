require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

    map({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", "Stage hunk")
    map({ "n", "v" }, "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", "Reset hunk")
    map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", "Stage buffer")
    map("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", "Reset buffer")
    map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk")
    map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")

    map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<CR>", "Hunk text object")
  end,
})
