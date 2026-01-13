---
description: Documents Go code in the given file
agent: go-docs
---

**File to document:** `$1` 
**Function/Type (optional):** `$2`

Document the Go file specified in `$1`.

If `$2` is provided, only document that symbol. Otherwise, document all exported
declarations in the file.

Constraints:

- Only add or update GoDoc comments (package + exported declarations).
- Be super concise.
- Do not add non-doc inline comments.
- Do not change code behaviour.

Write changes directly to the file using the Edit tool.
