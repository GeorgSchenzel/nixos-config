return {
  id = "basic-movement",
  order = 2,
  category = "Basic Vim",
  title = "Basic Movement",
  keys = "hjkl",
  explanation = [[
# Basic Movement

While in *normal mode*, `h` `j` `k` `l` move your cursor one character:
- `h` left
- `j` down
- `k` up
- `l` right

## Why not the arrow keys?

Vim is about efficiency — keeping your hands on the home row.
The arrow keys force your right hand off the row every time you move.
`hjkl` keeps you planted.

Rest your fingers on the home row:
- right hand on `j k l ;`
- left hand on `a s d f`

Your goal: move the cursor onto the green target as fast as you can,
15 times. Use the correct fingers.
]],
  examples = {
    {
      code = "function greet() {\n  return 'hi';\n}",
      replay = { "j", "l", "l", "l" },
      note = "down one line, then right three",
    },
  },
  practice = {
    buffer_lines = {
      "// Welcome to nvim-hero! Move the cursor onto the green target.",
      "// Use h j k l. Keep your fingers on the home row.",
      "",
      "function setGreeting(greeting) {",
      "  const element = document.getElementById('greeting');",
      "  element.innerText = greeting;",
      "}",
      "",
      "setGreeting('Hello World!');",
    },
    win = { kind = "cursor_at", count = 15 },
  },
}
