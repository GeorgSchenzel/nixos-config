local status = {}

local s = { win = nil, title = "", total = 0, hit = 0, mode = "targets", running = false }

local function fmt_time(ms)
  local ms0 = math.floor(ms) % 1000
  local ss = math.floor(ms / 1000) % 60
  local mm = math.floor(ms / 60000)
  return string.format("%02d:%02d.%03d", mm, ss, ms0)
end

function status.render()
  if not (s.win and vim.api.nvim_win_is_valid(s.win)) then return end
  local t = require("nvim-hero.timer").elapsed_ms()
  local rhs
  if s.mode == "edit" then
    rhs = string.format("edit %d/%d", s.hit, s.total)
  else
    rhs = string.format("● %d/%d", s.hit, s.total)
  end
  local bar = string.format(" ⏱ %s  %%=  %s  ·  %s ", fmt_time(t), rhs, s.title)
  vim.wo[s.win].winbar = bar
end

function status.start(win, title, total, mode)
  s.win, s.title, s.total, s.hit, s.mode = win, title, total or 1, 0, mode or "targets"
  s.running = true
  status.render()
  local function tick()
    if not s.running then return end
    status.render()
    vim.defer_fn(tick, 100)
  end
  tick()
end

function status.set_hit(hit)
  s.hit = hit
  status.render()
end

function status.stop()
  s.running = false
  require("nvim-hero.timer").stop()
  status.render()
end

return status
