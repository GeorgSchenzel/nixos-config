local highlight = {}

highlight.ns = vim.api.nvim_create_namespace("nvim-hero")

function highlight.define_highlights()
  local opts = require("nvim-hero.config").options
  local groups = {
    NvimHeroTarget  = opts.target_hl,
    NvimHeroHint    = opts.hint_hl,
    NvimHeroDelete  = { bg = "#ef4444", fg = "#ffffff", bold = true },
    NvimHeroBorder  = { fg = "#22c55e" },
    NvimHeroTitle   = { fg = "#22c55e", bold = true },
    NvimHeroMuted   = { fg = "#64748b" },
    NvimHeroSuccess = { fg = "#22c55e", bold = true },
  }
  for name, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, name, hl)
  end
end

function highlight.target(buf, line, col_start, col_end)
  col_end = col_end or col_start
  vim.api.nvim_buf_set_extmark(buf, highlight.ns, line - 1, col_start - 1, {
    end_col = col_end,
    hl_group = "NvimHeroTarget",
    priority = 10000,
    strict = false,
  })
end

function highlight.clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, highlight.ns, 0, -1)
end

function highlight.render_edit(buf, edit)
  highlight.clear(buf)
  local row = edit.line - 1
  if edit.current == "" then
    local text = require("nvim-hero.buffer").line_text(buf, edit.line)
    local line_len = #text
    local overlay_col0 = math.min(edit.col - 1, line_len)
    if edit.col <= line_len then
      highlight.target(buf, edit.line, edit.col)
    end
    vim.api.nvim_buf_set_extmark(buf, highlight.ns, row, overlay_col0, {
      virt_text = { { edit.replacement, "NvimHeroTarget" } },
      virt_text_pos = "inline",
      priority = 10001,
      strict = false,
    })
  else
    local start0 = edit.col - 1
    vim.api.nvim_buf_set_extmark(buf, highlight.ns, row, start0, {
      end_col = start0 + #edit.current,
      hl_group = "NvimHeroDelete",
      priority = 10000,
      strict = false,
    })
    if edit.replacement ~= "" then
      vim.api.nvim_buf_set_extmark(buf, highlight.ns, row, start0, {
        virt_text = { { edit.replacement, "NvimHeroDelete" } },
        virt_text_pos = "overlay",
        priority = 10001,
        strict = false,
      })
    end
  end
end

return highlight
