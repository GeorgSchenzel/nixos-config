local source = {}

local OPEN, CLOSE, SEP = "{{", "}}", "|"

local function parse_line(text)
  local buffer, expected = {}, {}
  local edits = {}
  local buf_col = 1
  local i = 1
  while i <= #text do
    if text:sub(i, i + #OPEN - 1) == OPEN then
      local close_start = text:find(CLOSE, i + #OPEN, true)
      if not close_start then
        error("nvim-hero: unclosed " .. OPEN .. " in source line: " .. text)
      end
      local inner = text:sub(i + #OPEN, close_start - 1)
      local bar = inner:find(SEP, 1, true)
      if not bar then
        error("nvim-hero: missing '" .. SEP .. "' in " .. OPEN .. inner .. CLOSE)
      end
      local current = inner:sub(1, bar - 1)
      local replacement = inner:sub(bar + #SEP)
      if current == "" and replacement == "" then
        error("nvim-hero: empty edit " .. OPEN .. CLOSE .. " in: " .. text)
      end
      table.insert(edits, { col = buf_col, current = current, replacement = replacement })
      table.insert(buffer, current)
      table.insert(expected, replacement)
      buf_col = buf_col + #current
      i = close_start + #CLOSE
    else
      local ch = text:sub(i, i)
      table.insert(buffer, ch)
      table.insert(expected, ch)
      buf_col = buf_col + 1
      i = i + 1
    end
  end
  return table.concat(buffer), table.concat(expected), edits
end

function source.parse(source_lines)
  local buffer_lines, expected_lines, edits = {}, {}, {}
  for lineno, src in ipairs(source_lines) do
    local b, e, le = parse_line(src)
    table.insert(buffer_lines, b)
    table.insert(expected_lines, e)
    for _, ed in ipairs(le) do
      ed.line = lineno
      table.insert(edits, ed)
    end
  end
  return { buffer_lines = buffer_lines, expected_lines = expected_lines, edits = edits }
end

return source
