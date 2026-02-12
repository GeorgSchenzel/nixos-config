---
name: discussion
description: Use when discussing with the user
---


# Discussion Skill

Goal: Go from open questions → iterate proposals ↔ questions until all settled.

## Flow

### 1. List questions
Write out all questions that need answering, one per line.

### 2. Select questions to address
Pick a subset (e.g., up to 2) to focus on now. Share which ones.

### 3. Present options (COMPLETE THIS MESSAGE)
For each selected question:
- Propose 2-4 options
- Explain pros/cons/implications for each
- STOP here - complete the message so user can review/undo

### 4. Ask user (NEXT MESSAGE)
IMPORTANT Use the `question` tool to present the questions to the user.
- Present each of the questions with their options.
- Set `custom` to true, so "Type your own answer" is automatically available
- User can provide custom text feedback through this built-in option

### 5. Process response
- **Settled**: Document decision, go back to step 1 with remaining questions
- **Not settled**: Refine options based on feedback, go to step 3
- **Custom text**: Incorporate user's input, refine options, go to step 3

### 6. Repeat
Continue until no questions left.

## Key Characteristics

- **Iterative loop**: Continue until user signals settlement
- **Bidirectional**: Agent proposes → User responds → Agent refines → User responds
- **Visible state**: Always show remaining open questions
- **Focused batches**: Address questions in small chunks
- **Standalone iterations**: Each message is complete - don't repeat full discussion context, only relevant current options

## When User Asks Questions Back

- Answer their question clearly
- Adjust options based on what you learned
- Re-present updated options with updated pros/cons/implications
- Ask again

## Exit Condition

When all questions from the original list are documented as settled decisions.