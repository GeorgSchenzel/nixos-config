local buffer_lines = {
  "// Move by words: w (next word start), e (word end), b (back).",
  "// Word motions jump between words, skipping whitespace.",
  "",
  "const greeting = computeGreeting('World');",
  "",
  "function computeGreeting(name) {",
  "  return `Hello, ${name}!`;",
  "}",
  "",
  "export default computeGreeting;",
}

return {
  id = "moving-with-words",
  order = 3,
  category = "Basic Vim",
  title = "Moving by Words",
  keys = "web",
  explanation = [[
# Moving by Words

Character-by-character motion (`hjkl`) is precise but slow over long
lines. Word motions leap across words:

- `w` — jump to the **start** of the next word
- `e` — jump to the **end** of the current/next word
- `b` — jump **back** to the start of the previous word

A "word" is a run of letters/digits/underscores, or a run of other
non-whitespace characters. Symbols like `(`, `=`, `'` each count as
their own word.

Move the cursor onto each green target. Use `w`/`e`/`b` instead of
repeating `h`/`l` — fewer keystrokes, less finger travel.
]],
  examples = {
    {
      code = "const total = computeSum(a, b);",
      replay = { "w", "w", "e", "b" },
      note = "hop across words: next, next, end, back",
    },
  },
  practice = {
    buffer_lines = buffer_lines,
    win = { kind = "cursor_at", count = 15, placement = "word" },
  },
}
