return {
  id = "insert",
  order = 4,
  category = "Basic Vim",
  title = "Insert Mode",
  keys = "iaAesc",
  explanation = [[
# Insert Mode

Press `i` to enter insert mode **before** the cursor, `a` to enter it
**after** (append), and `A` to append at the **end of the line**.

Press `<Esc>` to leave insert mode and return to normal mode.

Your goal: each line is missing one character. The green marker shows
**where** to insert and the inline overlay shows **what** to type. Use
whichever of `i` / `a` / `A` gets you there — the drill practices
entering insert mode and typing.

Advance through all 10 lines as fast as you can.
]],
  examples = {
    {
      code = "let x =1",
      replay = { "$a;<Esc>" },
      note = "$ to end of line, 'a' to append, ';' then <Esc>",
    },
  },
  practice = {
    source_lines = {
      "let alpha ={{| }}1;",
      "let beta{{| }}= 2;",
      "let gamma = 3{{|;}}",
      "let delta ={{| }}4;",
      "let eps{{| }}= 5;",
      "let zeta = 6{{|;}}",
      "let eta ={{| }}7;",
      "let theta{{| }}= 8;",
      "let iota = 9{{|;}}",
      "let kappa ={{| }}10;",
    },
    win = { kind = "buffer_equals" },
  },
}
