local timer = {}

local s = { start_rel = nil, final_ms = 0, running = false }

function timer.start()
  s.start_rel = vim.fn.reltime()
  s.final_ms = 0
  s.running = true
end

function timer.elapsed_ms()
  if s.running and s.start_rel then
    return vim.fn.reltimefloat(vim.fn.reltime(s.start_rel)) * 1000
  end
  return s.final_ms
end

function timer.stop()
  if s.running then
    s.final_ms = timer.elapsed_ms()
  end
  s.running = false
end

function timer.is_running() return s.running end

return timer
