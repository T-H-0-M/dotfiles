---
description: Documents code in the given file (auto-detects language)
---

**File to document:** `$ARG1`
**Function/Component/Type (optional):** `$ARG2`

## Language Detection

First, determine the language of the file specified in `$ARG1` by examining its file extension:

- **TypeScript/JavaScript/React Native**: `.ts`, `.tsx`, `.js`, `.jsx`
- **Go**: `.go`

## Command Routing

Based on the detected language, invoke the appropriate language-specific document command:

### For TypeScript/JavaScript/React Native files:
Use the `/document-ts` command with the same arguments.

### For Go files:
Use the `/document-go` command with the same arguments.

### For unsupported languages:
Inform the user that documentation for this language is not yet supported and list the currently supported languages:
- TypeScript/React Native (use `/document-ts`)
- Go (use `/document-go`)

---
