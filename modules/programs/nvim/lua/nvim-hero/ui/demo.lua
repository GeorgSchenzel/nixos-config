local demo = {}

local state = { win = nil, buf = nil, augroup = nil, stopped = true }

local function close()
  state.stopped = true
  if state.augroup then
    pcall(vim.api.nvim_clear_autocmds, { group = state.augroup })
    state.augroup = nil
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win, state.buf = nil, nil
end

function demo.play(example, opts)
  opts = opts or {}
  close()
  if not (example and example.code) then return end

  local lines = vim.split(example.code, "\n", { trimempty = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.min(72, vim.o.columns - 4)
  local height = math.min(math.max(#lines + 1, 3), vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.max(0, row),
    col = math.max(0, col),
    width = width,
    height = height,
    border = "rounded",
    title = " demo ",
    title_pos = "center",
    style = "minimal",
  })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = true
  vim.wo[win].signcolumn = "no"

  state.buf, state.win, state.stopped = buf, win, false
  pcall(vim.api.nvim_win_set_cursor, win, { 1, 0 })

  local note = example.note and (example.note .. "  ") or ""
  local delay = opts.delay or 650
  local keys = {}
  for _, k in ipairs(example.replay or {}) do table.insert(keys, k) end

  local function set_bar(label)
    if win and vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winbar = " " .. note .. label
    end
  end

  local function step(i)
    if state.stopped then return end
    if not (win and vim.api.nvim_win_is_valid(win)) then return end
    local k = keys[i]
    if not k then
      set_bar("done — [q]/[<esc>] to close")
      return
    end
    local shown = k:gsub("<", "<"):gsub(">", ">")
    set_bar("press: [" .. shown .. "]")
    local code = vim.api.nvim_replace_termcodes(k, true, false, true)
    pcall(vim.cmd, "normal! " .. code)
    vim.defer_fn(function() step(i + 1) end, delay)
  end

  state.augroup = vim.api.nvim_create_augroup("nvim-hero-demo", { clear = true })
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    group = state.augroup, buffer = buf, once = true, callback = close,
  })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<esc>", close, { buffer = buf, nowait = true, silent = true })

  set_bar(note .. "starting…")
  vim.defer_fn(function() step(1) end, opts.start_delay or 500)
end

demo.close = close
return demo
