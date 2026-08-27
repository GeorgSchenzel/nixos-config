local doubt = require("doubt")

doubt.setup({
  keymaps = {
    export = false,
    export_picker = false,
  },
})

local function notes_paths()
  local state = require("doubt.state")
  local paths = {}
  for path, file_state in pairs(state.current_files()) do
    if not vim.tbl_isempty(file_state.claims or {}) then
      paths[#paths + 1] = path
    end
  end
  table.sort(paths)
  return paths
end

local function copy_notes()
  local state = require("doubt.state")
  local files = state.current_files()
  local lines = {}
  for _, path in ipairs(notes_paths()) do
    local rel = vim.fn.fnamemodify(path, ":.")
    for _, claim in ipairs(files[path].claims) do
      local first = claim.start_line + 1
      local last = claim.end_line + 1
      local range = first == last and tostring(first) or (first .. "-" .. last)
      local note = (claim.note or ""):gsub("%s*\n%s*", " ")
      lines[#lines + 1] = ("%s:%s [%s] %s"):format(rel, range, claim.kind, note)
    end
  end

  if #lines == 0 then
    vim.notify("No doubt notes to copy", vim.log.levels.INFO)
    return
  end

  vim.fn.setreg("+", table.concat(lines, "\n"))
  vim.notify(("Copied %d doubt notes"):format(#lines))
end

local function clear_all_notes()
  local paths = notes_paths()
  if #paths == 0 then
    vim.notify("No doubt notes to clear", vim.log.levels.INFO)
    return
  end
  for _, path in ipairs(paths) do
    doubt.delete_file({ path = path })
  end
end

vim.schedule(function()
  vim.keymap.set("n", "<leader>De", copy_notes, { desc = "Copy doubt notes" })
  vim.keymap.set("n", "<leader>DA", clear_all_notes, { desc = "Clear all doubt notes" })
end)

local state = require("doubt.state")
if not state.has_active_session() then
  local name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  if name == "" then
    name = "default"
  end
  doubt.start_session({ name = name, quiet = true })
end
