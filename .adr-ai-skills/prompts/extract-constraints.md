# Prompt: Extract Constraints from ADR

## Purpose
Extract machine-readable constraints from an ADR document for constraints.json.

## Input
```
ADR Content: {full ADR markdown}
```

## Prompt

You are extracting machine-readable constraints from an Architecture Decision Record.

Parse the following ADR and extract constraints that can be automatically checked.

**ADR Content:**
{input}

**Output Format:**
```json
{
  "id": "ADR-{NUMBER}",
  "description": "{one line summary}",
  "weight": {total score from ADR},
  "enforcement": "required|recommended|deprecated",
  "forbidden": [
    "{patterns that must not appear in code}"
  ],
  "required": [
    "{patterns or structures that must exist}"
  ],
  "scope": [
    "{directories or file patterns where this applies}"
  ],
  "checkType": "{how to verify this constraint}",
  "exceptions": [
    "{paths or patterns exempt from this rule}"
  ]
}
```

**Check Types:**
- `grep_forbidden`: Search for forbidden patterns in code
- `grep_required`: Ensure required patterns exist
- `directory_exists`: Verify directory structure
- `file_exists`: Verify specific files exist
- `pattern_match`: Complex pattern matching
- `llm_review`: Requires AI judgment (use sparingly)

**Guidelines:**
1. Be specific with patterns - avoid overly broad matches
2. Scope should be as narrow as possible while covering the intent
3. Use `llm_review` only when rule cannot be expressed as pattern
4. Include exceptions for legitimate edge cases

## Example Output

```json
{
  "id": "ADR-0003",
  "description": "No direct tokio usage in backend",
  "weight": 10,
  "enforcement": "required",
  "forbidden": [
    "use tokio::",
    "tokio::runtime",
    "#[tokio::main]"
  ],
  "required": [],
  "scope": [
    "backend/**",
    "wasm-core/**"
  ],
  "checkType": "grep_forbidden",
  "exceptions": [
    "backend/tests/**"
  ]
}
```
