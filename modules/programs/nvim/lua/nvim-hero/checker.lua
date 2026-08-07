local checker = {}

math.randomseed(os.time())
for _ = 1, 8 do math.random() end

local function char_class(c)
  if c == "" or c == " " or c == "\t" then return 0 end
  if c:match("[A-Za-z0-9_]") then return 1 end
  return 2
end

local function word_positions(text)
  local pos = {}
  local prev = 0
  for i = 1, #text do
    local cl = char_class(text:sub(i, i))
    local nxt = char_class(text:sub(i + 1, i + 1))
    if cl ~= 0 then
      if cl ~= prev then table.insert(pos, i) end
      if cl ~= nxt then table.insert(pos, i) end
    end
    prev = cl
  end
  return pos
end

local function random_word_target(buf, opts)
  local bufmod = require("nvim-hero.buffer")
  local avoid_line, avoid_col = opts.avoid_line, opts.avoid_col
  local min_distance = opts.min_distance or 3
  local min_line = opts.min_line or 1
  local candidates = {}
  for l = min_line, bufmod.line_count(buf) do
    local text = bufmod.line_text(buf, l)
    for _, col in ipairs(word_positions(text)) do
      table.insert(candidates, { line = l, col = col })
    end
  end
  if #candidates == 0 then
    return { line = math.max(1, min_line), col = 1 }
  end
  for _ = 1, 100 do
    local t = candidates[math.random(1, #candidates)]
    local same = (t.line == avoid_line)
    if not (same and math.abs(t.col - (avoid_col or 0)) < min_distance) then
      return t
    end
  end
  return candidates[1]
end

function checker.random_target(buf, opts)
  opts = opts or {}
  if opts.placement == "word" then
    return random_word_target(buf, opts)
  end
  local avoid_line, avoid_col = opts.avoid_line, opts.avoid_col
  local min_distance = opts.min_distance or 4
  local min_col = opts.min_col or 1
  local min_line = opts.min_line or 1
  local bufmod = require("nvim-hero.buffer")
  local n = bufmod.line_count(buf)
  for _ = 1, 400 do
    local line = math.random(min_line, n)
    local text = bufmod.line_text(buf, line)
    if #text >= min_col + 2 then
      local col = math.random(min_col, #text)
      local same_line = (line == avoid_line)
      local too_close = same_line and math.abs(col - (avoid_col or 0)) < min_distance
      if not too_close then
        return { line = line, col = col }
      end
    end
  end
  return { line = math.max(min_line, 1), col = math.max(1, min_col) }
end

function checker.cursor_at(win, target)
  if not (win and vim.api.nvim_win_is_valid(win)) then return false end
  local pos = vim.api.nvim_win_get_cursor(win)
  return pos[1] == target.line and (pos[2] + 1) == target.col
end

function checker.buffer_equals(buf, expected_lines)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  local actual = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #actual ~= #expected_lines then return false end
  for i = 1, #actual do
    if actual[i] ~= expected[i] then return false end
  end
  return true
end

return checker
