local stats = {}

local cache = nil

local function path()
  return vim.fn.stdpath("data") .. "/nvim-hero.json"
end

function stats.load()
  if cache then return cache end
  local f = io.open(path(), "r")
  if not f then cache = {} return cache end
  local content = f:read("*a") or ""
  f:close()
  cache = (content ~= "" and vim.fn.json_decode(content)) or {}
  if type(cache) ~= "table" then cache = {} end
  return cache
end

function stats.save()
  if not cache then return end
  vim.fn.mkdir(vim.fn.stdpath("data"), "p")
  local f, err = io.open(path(), "w")
  if not f then
    vim.schedule(function() vim.notify("nvim-hero: could not save stats: " .. tostring(err), vim.log.levels.WARN) end)
    return
  end
  f:write(vim.fn.json_encode(cache))
  f:close()
end

function stats.record(lesson_id, elapsed_ms)
  local data = stats.load()
  local e = data[lesson_id] or { attempts = 0 }
  local is_best = (e.best_ms == nil) or (elapsed_ms < e.best_ms)
  e.attempts = (e.attempts or 0) + 1
  e.last_ms = elapsed_ms
  if is_best then e.best_ms = elapsed_ms end
  data[lesson_id] = e
  stats.save()
  return {
    attempts = e.attempts,
    last_ms = e.last_ms,
    best_ms = e.best_ms,
    is_best = is_best,
  }
end

function stats.get(lesson_id)
  return stats.load()[lesson_id]
end

function stats.reset(lesson_id)
  local data = stats.load()
  data[lesson_id] = nil
  stats.save()
end

return stats
