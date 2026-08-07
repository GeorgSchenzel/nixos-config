local lessons = {}

local function normalize(lesson)
  local p = lesson.practice
  if p and p.source_lines and not p._parsed then
    local parsed = require("nvim-hero.source").parse(p.source_lines)
    p.buffer_lines = parsed.buffer_lines
    p.win = p.win or {}
    p.win.expected_lines = parsed.expected_lines
    p.edits = parsed.edits
    p._parsed = true
  end
  return lesson
end

function lessons.list()
  local files = vim.api.nvim_get_runtime_file("lua/nvim-hero/lessons/*.lua", true)
  local found = {}
  for _, f in ipairs(files) do
    local mod = f:match("lua/nvim%-hero/lessons/(.-)%.lua$")
    if mod and mod ~= "init" then
      local ok, lesson = pcall(require, "nvim-hero.lessons." .. mod)
      if ok and lesson and lesson.id then
        lesson._mod = mod
        normalize(lesson)
        table.insert(found, lesson)
      end
    end
  end
  table.sort(found, function(a, b) return (a.order or 999) < (b.order or 999) end)
  return found
end

return lessons
