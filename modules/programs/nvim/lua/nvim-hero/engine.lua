local engine = {}

local state = {
  lesson = nil,
  buf = nil,
  win = nil,
  tab = nil,
  prev_tab = nil,
  sidebar_win = nil,
  sidebar_buf = nil,
  target = nil,
  hit = 0,
  total = 0,
  win_kind = nil,
  augroup = nil,
  running = false,
  timer_armed = false,
  expected_lines = nil,
  edits = nil,
  placement = nil,
}

local function clear_target()
  state.target = nil
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    require("nvim-hero.highlight").clear(state.buf)
  end
end

local function place_target()
  local hl = require("nvim-hero.highlight")
  local checker = require("nvim-hero.checker")
  local buf = state.buf
  if not buf then return end
  hl.clear(buf)
  local cur = { 1, 0 }
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    cur = vim.api.nvim_win_get_cursor(state.win)
  end
  state.target = checker.random_target(buf, {
    avoid_line = cur[1],
    avoid_col = cur[2] + 1,
    placement = state.placement,
  })
  hl.target(buf, state.target.line, state.target.col)
end

local function arm_timer()
  if state.timer_armed then
    state.timer_armed = false
    require("nvim-hero.timer").start()
  end
end

local function on_cursor_moved()
  if not state.running then return end
  arm_timer()
  if not state.target then return end
  if require("nvim-hero.checker").cursor_at(state.win, state.target) then
    state.hit = state.hit + 1
    require("nvim-hero.status").set_hit(state.hit)
    clear_target()
    if state.hit >= state.total then
      engine.finish()
    else
      place_target()
    end
  end
end

local function compute_progress()
  local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
  local done, active = 0, nil
  for _, e in ipairs(state.edits) do
    if (lines[e.line] or "") == (state.expected_lines[e.line] or "") then
      done = done + 1
    elseif not active then
      active = e
    end
  end
  return active, done, #state.edits
end

local function render_transform()
  local active, done, total = compute_progress()
  require("nvim-hero.status").set_hit(done)
  if active then
    require("nvim-hero.highlight").render_edit(state.buf, active)
  else
    require("nvim-hero.highlight").clear(state.buf)
  end
  return done >= total
end

local function on_transform_change()
  if not state.running then return end
  arm_timer()
  if render_transform() then
    engine.finish()
  end
end

local function open_layout(lesson, sidebar_w)
  state.prev_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd("tabnew")
  state.tab = vim.api.nvim_get_current_tabpage()

  local buf = require("nvim-hero.buffer").create(lesson.practice.buffer_lines)
  vim.api.nvim_set_current_buf(buf)
  state.buf = buf
  state.win = vim.api.nvim_get_current_win()

  if lesson.practice.win.kind == "cursor_at" then
    vim.bo[buf].modifiable = false
  end

  vim.cmd("botright vnew")
  local sb_buf = require("nvim-hero.ui.explain").create_buf(lesson)
  vim.api.nvim_set_current_buf(sb_buf)
  state.sidebar_buf = sb_buf
  state.sidebar_win = vim.api.nvim_get_current_win()

  pcall(vim.api.nvim_win_set_width, state.win, vim.o.columns - sidebar_w - 2)

  for _, opt in ipairs({ "number", "relativenumber", "cursorline" }) do
    vim.wo[state.win][opt] = false
  end
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].wrap = false

  vim.wo[state.sidebar_win].number = false
  vim.wo[state.sidebar_win].relativenumber = false
  vim.wo[state.sidebar_win].cursorline = false
  vim.wo[state.sidebar_win].signcolumn = "no"
  vim.wo[state.sidebar_win].wrap = true
  vim.wo[state.sidebar_win].conceallevel = 2
  vim.wo[state.sidebar_win].concealcursor = "n"

  vim.api.nvim_set_current_win(state.win)
  pcall(vim.api.nvim_win_set_cursor, state.win, { 1, 0 })
end

local function setup_autocmds(kind)
  state.augroup = vim.api.nvim_create_augroup("nvim-hero-practice", { clear = true })
  if kind == "cursor_at" then
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = state.augroup, buffer = state.buf, callback = on_cursor_moved,
    })
  elseif kind == "buffer_equals" then
    for _, ev in ipairs({ "TextChanged", "TextChangedI", "InsertLeave" }) do
      vim.api.nvim_create_autocmd(ev, {
        group = state.augroup, buffer = state.buf, callback = on_transform_change,
      })
    end
  end
  vim.api.nvim_create_autocmd("BufDelete", {
    group = state.augroup, buffer = state.buf, once = true,
    callback = function() engine.stop_lesson() end,
  })
end

function engine.start_lesson(lesson)
  engine.stop_lesson()
  state.lesson = lesson
  state.hit = 0
  local spec = lesson.practice.win
  state.win_kind = spec.kind

  local sidebar_w = require("nvim-hero.ui.explain").sidebar_width()
  open_layout(lesson, sidebar_w)

  if spec.kind == "cursor_at" then
    state.total = spec.count or require("nvim-hero.config").options.target_count
    state.placement = spec.placement
    require("nvim-hero.status").start(state.sidebar_win, lesson.title, state.total, "targets")
  elseif spec.kind == "buffer_equals" then
    state.expected_lines = spec.expected_lines
    state.edits = lesson.practice.edits or {}
    state.total = #state.edits
    require("nvim-hero.status").start(state.sidebar_win, lesson.title, state.total, "edit")
    render_transform()
  end

  setup_autocmds(spec.kind)

  local function bufmap(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = state.buf, nowait = true, silent = true, desc = desc })
  end
  bufmap("<leader>q", function() engine.stop_lesson() end, "nvim-hero: abort lesson")
  if spec.kind == "cursor_at" then
    bufmap("q", function() engine.stop_lesson() end, "nvim-hero: quit")
  end
  if lesson.examples and lesson.examples[1] then
    bufmap("<leader>d", function()
      require("nvim-hero.ui.demo").play(lesson.examples[1])
    end, "nvim-hero: play example demo")
  end

  state.timer_armed = true
  state.running = true
  if spec.kind == "cursor_at" then
    place_target()
  end
end

function engine.finish()
  if not state.running then return end
  state.running = false
  state.timer_armed = false
  clear_target()
  require("nvim-hero.status").stop()
  local elapsed = require("nvim-hero.timer").elapsed_ms()
  local total = state.total
  local rec = require("nvim-hero.stats").record(state.lesson.id, elapsed)
  vim.defer_fn(function()
    engine.show_results(state.lesson, elapsed, total, rec)
  end, 80)
end

function engine.show_results(lesson, elapsed_ms, total, rec)
  require("nvim-hero.ui.results").open({
    title = lesson.title,
    hit = total,
    total = total,
    elapsed_ms = elapsed_ms,
    record = rec,
    on_replay = function() engine.start_lesson(lesson) end,
    on_menu = function() require("nvim-hero.ui.menu").open() end,
    on_close = function() engine.stop_lesson() end,
  })
end

function engine.stop_lesson()
  state.running = false
  state.timer_armed = false
  require("nvim-hero.status").stop()
  if state.augroup then
    pcall(vim.api.nvim_clear_autocmds, { group = state.augroup })
    state.augroup = nil
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
  if state.sidebar_buf and vim.api.nvim_buf_is_valid(state.sidebar_buf) then
    pcall(vim.api.nvim_buf_delete, state.sidebar_buf, { force = true })
  end
  state.buf, state.sidebar_buf = nil, nil
  if state.tab and vim.api.nvim_tabpage_is_valid(state.tab) then
    pcall(vim.api.nvim_set_current_tabpage, state.tab)
    if vim.api.nvim_tabpage_is_valid(state.tab) then
      pcall(vim.cmd, "tabclose " .. vim.api.nvim_tabpage_get_number(state.tab))
    end
  end
  if state.prev_tab and vim.api.nvim_tabpage_is_valid(state.prev_tab) then
    pcall(vim.api.nvim_set_current_tabpage, state.prev_tab)
  end
  state.lesson = nil
  state.win = nil
  state.tab = nil
  state.prev_tab = nil
  state.sidebar_win = nil
  state.target = nil
  state.win_kind = nil
  state.expected_lines = nil
  state.edits = nil
  state.placement = nil
  state.hit, state.total = 0, 0
end

function engine.is_running() return state.running end

return engine
