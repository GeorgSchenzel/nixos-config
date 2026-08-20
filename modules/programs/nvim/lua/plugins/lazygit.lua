local function git_root()
  local root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd()
  end
  return (root:gsub("%s+$", ""))
end

vim.keymap.set("n", "<leader>gg", function()
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " lazygit ",
    title_pos = "center",
  })

  vim.bo[buf].bufhidden = "wipe"

  -- After <C-\><C-n>, let q close the float from Normal mode too.
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "Close lazygit" })

  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    cwd = git_root(),
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })

  vim.cmd.startinsert()
end, { desc = "Lazygit (git root)" })
