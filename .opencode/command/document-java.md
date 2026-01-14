---
description: Documents Java code in the given file
agent: java-docs
---

**File to document:** `$1`
**Class/Method/Field (optional):** `$2`

Document the Java file specified in `$1`.

If `$2` is provided, only document that symbol. Otherwise, document the public/protected API in the file.

Constraints:
- Only add or update JavaDoc blocks (`/** ... */`).
- Be super concise.
- Do not add non-doc inline comments.
- Do not change code behaviour.

Write changes directly to the file using the Edit tool.
