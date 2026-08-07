local menu = {}

local state = { win = nil, buf = nil, lessons = {}, first_row = 0 }

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf, state.lessons, state.first_row = nil, nil, {}, 0
end

local function open()
  close()
  state.lessons = require("nvim-hero.lessons").list()
  local stats = require("nvim-hero.stats")

  local lines = {
    "  nvim-hero",
    "  " .. string.rep("─", 50),
    "",
    "  Select a lesson:",
    "",
  }
  state.first_row = #lines + 1
  if #state.lessons == 0 then
    table.insert(lines, "  (no lessons found)")
  else
    for i, l in ipairs(state.lessons) do
      local rec = stats.get(l.id)
      local done = rec and rec.best_ms ~= nil
      local mark = done and "✓" or " "
      local best = rec and rec.best_ms
          and string.format("(%.2fs)", rec.best_ms / 1000)
          or ""
      local cat = l.category and ("[" .. l.category .. "] ") or ""
      table.insert(
        lines,
        string.format(" %s %d. %-26s %7s  %s%s", mark, i, l.title, best, cat, l.keys or "")
      )
    end
  end
  table.insert(lines, "")
  table.insert(lines, "  " .. string.rep("─", 50))
  table.insert(lines, "  <number>/<CR> start · q quit")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "nvim-hero-menu"

  for i, l in ipairs(state.lessons) do
    if stats.get(l.id) then
      local row = state.first_row + i - 1
      pcall(vim.api.nvim_buf_add_highlight, buf, 0, "NvimHeroSuccess", row - 1, 1, 2)
    end
  end

  local width = 56
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.max(0, row),
    col = math.max(0, col),
    width = width,
    height = height,
    border = "rounded",
    title = " nvim-hero ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"

  state.buf, state.win = buf, win

  local function pick(idx)
    local lesson = state.lessons[idx]
    if not lesson then return end
    close()
    require("nvim-hero.engine").start_lesson(lesson)
  end

  for i = 1, #state.lessons do
    vim.keymap.set("n", tostring(i), function() pick(i) end,
      { buffer = buf, nowait = true, silent = true })
  end
  vim.keymap.set("n", "<CR>", function()
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    local idx = cursor_line - state.first_row + 1
    if idx >= 1 and idx <= #state.lessons then pick(idx) end
  end, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<esc>", close, { buffer = buf, nowait = true, silent = true })
end

menu.open = open
menu.close = close

return menu
