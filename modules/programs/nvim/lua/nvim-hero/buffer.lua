local buffer = {}

buffer.NAME = "nvim-hero://practice"

function buffer.create(buffer_lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_lines)
  vim.bo[buf].modified = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "nvim-hero-practice"
  vim.api.nvim_buf_set_name(buf, buffer.NAME)
  return buf
end

function buffer.line_text(buf, lnum)
  local lines = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)
  return lines[1] or ""
end

function buffer.line_count(buf)
  return vim.api.nvim_buf_line_count(buf)
end

return buffer
