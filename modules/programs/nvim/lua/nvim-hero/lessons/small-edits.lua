return {
  id = "small-edits",
  order = 5,
  category = "Basic Vim",
  title = "Small Edits",
  keys = "sxr",
  explanation = [[
# Small Edits

Three quick normal-mode edits that act on a single character:

- `x` — delete the character under the cursor
- `r{char}` — replace the character under the cursor with `{char}`
- `s` — delete the character under the cursor and enter insert mode
        (substitute), so you can type a replacement of any length

The red marker shows the character to change; the overlay shows what it
should become. Use `x` to delete, `r` to swap one char, or `s` when the
replacement is a whole word.

Fix all 10 lines.
]],
  examples = {
    {
      code = "helloo",
      replay = { "5l", "x" },
      note = "land on the doubled letter, delete it",
    },
  },
  practice = {
    source_lines = {
      "hell{{o|}}o",
      "ban{{n|}}ana",
      "boo{{k|}}ks",
      "sho{{p|}}p",
      "c{{e|a}}t",
      "d{{p|o}}g",
      "f{{u|i}}x",
      "r{{t|u}}n",
      "{{x|count}} = 1",
      "{{y|total}} = 2",
    },
    win = { kind = "buffer_equals" },
  },
}
