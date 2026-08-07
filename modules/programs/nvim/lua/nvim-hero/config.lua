local config = {}

config.defaults = {
  target_count = 15,
  target_hl = { bg = "#22c55e", fg = "#000000", bold = true },
  hint_hl = { fg = "#22c55e", bold = true },
  sidebar_width_ratio = 0.30,
  sidebar_min_width = 38,
  sidebar_max_width = 62,
}

config.options = {}

function config.setup(opts)
  config.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
  return config.options
end

return config
