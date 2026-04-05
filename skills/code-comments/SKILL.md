---
name: code-comments
description: >
  Enforces a strict, minimal comment style across a codebase or file. Use this skill whenever the user asks to
  clean up comments, apply a comment style, audit comments, fix documentation, add docstrings, remove unnecessary
  comments, or says anything like "tidy up the comments", "apply my comment style", "remove redundant comments",
  "add docs to my functions", or "comment cleanup". Trigger even if the user just pastes a file and says something
  like "apply my commenting rules" - this is the skill for that.
---

# Code Comment Style Enforcer

The user follows a disciplined commenting philosophy:

1. **Docstrings on every function and method** - a brief, plain-English description of what it does. No forced structure (no mandatory Args/Returns/Raises sections). Just enough that a reader understands the purpose without reading the body.
2. **Inline comments only for genuinely non-obvious code** - if there is any chance a future reader (including the author in 6 months) might stop and wonder *why* this works the way it does, a short inline comment earns its place. If the code speaks for itself, the comment adds noise.
3. **Pre-existing comments get audited** - do not wholesale delete or keep them. Read each one and ask: does this comment tell the reader something the code does not already say clearly? If yes, keep it (reword if it can be clearer). If no, remove it.

---

## Your job when this skill is triggered

The user will provide a file (or files) and a directive - something like "apply my comment style" or "clean up the comments". Your task is to return the full updated file(s) with comments applied according to the rules above.

### Step 1 - Read and understand the code

Before touching a single comment, read through the entire file. You need to understand what each function does and which pieces of logic are non-trivial. Do not just pattern-match on comment syntax - understand the code well enough to judge whether a comment earns its place.

### Step 2 - Process docstrings

For every function, method, or class that lacks a docstring, add one. It should:
- Be written in whatever docstring syntax is idiomatic for the language (triple-quoted strings in Python, JSDoc `/** */` in JS/TS, XML docs in C#, etc.)
- Be a single sentence or short paragraph describing *what* the function does, not *how*
- Avoid restating the function name or its parameter names back at the reader

If an existing docstring is accurate but verbose or redundant, tighten it up.

### Step 3 - Audit inline comments

For every inline or block comment that is not a docstring, apply this test:

> "If I deleted this comment, would a competent developer who knows this language be confused or surprised by this line?"

- If **yes** -> keep it. Reword it if it could be clearer or more concise.
- If **no** -> remove it.

Common comments that should be removed:
- Comments that just narrate what the next line obviously does (`# increment counter`, `// return the result`)
- Comments that restate the variable or function name (`# user list`, `// check if valid`)
- Commented-out code (unless the user's directive says otherwise)
- TODO/FIXME comments that are vague and clearly stale - use judgment; if they look active or specific, leave them

Comments that should stay (or be added):
- Explaining a non-obvious algorithm or mathematical trick
- Calling out a gotcha, edge case, or why a seemingly-wrong approach is actually correct
- Explaining *why* a workaround exists (for example, "browser bug in Safari < 15")
- Clarifying intent where the implementation is indirect or counterintuitive

### Step 4 - Output

Return the fully updated file. Do not summarize every change you made - just deliver the file. If there were a significant number of changes, a brief note at the end (2-3 sentences max) is fine to orient the user.

---

## Judgment calls

These rules are guidelines, not rigid checklists. Use your understanding of the code and context:

- A 3-line function that is completely obvious does not need a docstring that just says "Returns the sum." Write nothing, or write something actually useful.
- A complex regular expression almost always earns a comment explaining what it matches, even if it "works."
- Test files: apply the same rules - test function docstrings are often the most useful documentation in a codebase.
- If the language does not have docstrings (for example, C or Go), use a block comment above the function in the idiomatic style.

The goal is a codebase where every comment either teaches the reader something or confirms something they might have doubted - nothing more.
