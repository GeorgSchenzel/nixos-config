local results = {}

local state = { win = nil, buf = nil }

local function fmt_time(ms)
  return string.format("%.3fs", ms / 1000)
end

function results.open(opts)
  results.close()
  local rec = opts.record or {}
  local lines = {
    "",
    "  " .. (opts.title or "Lesson") .. " complete!",
    "  " .. string.rep("─", 38),
    string.format("  targets:  %d/%d", opts.hit or 0, opts.total or 0),
    string.format("  time:     %s", fmt_time(opts.elapsed_ms or 0)),
  }
  if rec.best_ms then
    local best = fmt_time(rec.best_ms)
    if rec.is_best then
      table.insert(lines, string.format("  best:     %s   ✦ new best!", best))
    else
      table.insert(lines, string.format("  best:     %s", best))
    end
    table.insert(lines, string.format("  attempts: %d", rec.attempts or 1))
  else
    table.insert(lines, string.format("  best:     %s   ✦ new best!", fmt_time(opts.elapsed_ms or 0)))
  end
  vim.list_extend(lines, {
    "  " .. string.rep("─", 38),
    "",
    "  [r] replay    [m] menu    [q] quit",
    "",
  })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "nvim-hero-results"

  local width = 44
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
    title = " Results ",
    title_pos = "center",
    noautocmd = true,
  })
  vim.wo[win].cursorline = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  state.buf, state.win = buf, win

  local function map(key, fn)
    vim.keymap.set("n", key, function()
      results.close()
      if fn then fn() end
    end, { buffer = buf, nowait = true, silent = true })
  end
  map("r", opts.on_replay)
  map("m", opts.on_menu)
  map("q", opts.on_close)
  map("<esc>", opts.on_close)
end

function results.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win, state.buf = nil, nil
end

return results
