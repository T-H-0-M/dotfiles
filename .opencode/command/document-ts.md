---
description: Documents TypeScript/React Native code in the given file
agent: ts-docs
---

**File to document:** `$1`
**Function/Component/Type (optional):** `$2`

Document the file specified in `$1`.

If `$2` is provided, only document that symbol. Otherwise, document exported API in the file.

Constraints:
- Only add or update TSDoc blocks (`/** ... */`).
- Be super concise.
- Do not add inline comments.
- Do not change code behaviour.

Write changes directly to the file using the Edit tool.
