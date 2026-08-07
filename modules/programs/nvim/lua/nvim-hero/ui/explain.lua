local explain = {}

function explain.sidebar_width()
  local opts = require("nvim-hero.config").options
  local w = math.floor(vim.o.columns * opts.sidebar_width_ratio)
  w = math.max(opts.sidebar_min_width, math.min(w, opts.sidebar_max_width))
  return math.min(w, math.floor(vim.o.columns * 0.45))
end

function explain.create_buf(lesson)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  local lines = vim.split(lesson.explanation or "(no explanation provided)", "\n", { trimempty = false })
  table.insert(lines, "")
  table.insert(lines, "──")
  table.insert(lines, string.format("keys: **%s**", lesson.keys or "?"))
  table.insert(lines, "")
  table.insert(lines, "`<leader>d` demo  ·  `<leader>q` abort")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  return buf
end

return explain
