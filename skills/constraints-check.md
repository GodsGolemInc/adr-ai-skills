# Skill: /constraints-check

Fast constraint checking skill for validating code against architectural rules defined in constraints.json.

## Commands

### /constraints-check [path]
Check specific path or entire codebase against constraints.

### /constraints-check --adr ADR-XXXX
Check only constraints from specific ADR.

### /constraints-check --update
Update constraints.json from current ADRs.

### /constraints-check --ci
CI-friendly output format (exit codes, minimal output).

## Workflow

```
1. Load docs/constraints.json
2. For each rule:
   - Determine check type
   - Execute check
   - Collect results
3. Aggregate and report
```

## Check Types

### grep_forbidden
Search for patterns that must not exist.

```bash
# For each forbidden pattern:
rg "{pattern}" --glob "{scope}" --files-with-matches
# If matches found: VIOLATION
```

### grep_required
Ensure required patterns exist.

```bash
# For each required pattern:
rg "{pattern}" --glob "{scope}" --files-with-matches
# If no matches: VIOLATION
```

### directory_exists
Verify directory structure.

```bash
# For each required directory:
test -d "{path}"
# If not exists: VIOLATION
```

### file_exists
Verify specific files exist.

```bash
# For each required file:
test -f "{path}"
# If not exists: VIOLATION
```

### pattern_match
Complex pattern matching (uses AST when available).

```
# Use tree-sitter or language-specific tooling
# to verify structural patterns
```

### llm_review
AI-assisted constraint checking for complex rules.

```
# Apply check-adr-violation.md prompt
# with relevant code context
```

## Output Format

### Standard Output

```
## Constraints Check

**Total Rules:** 5
**Checked:** 5
**Passed:** 4
**Failed:** 1

### Results

| ADR | Rule | Status | Details |
|-----|------|--------|---------|
| ADR-0000 | ADR directory exists | PASS | - |
| ADR-0003 | No tokio in backend | FAIL | 2 matches |
| ADR-0005 | Repository pattern | PASS | - |

### Failures

**ADR-0003: No tokio in backend**
- Weight: 10 (Critical)
- Check: grep_forbidden
- Matches:
  - backend/api.rs:45: `use tokio::spawn`
  - backend/worker.rs:12: `#[tokio::main]`
```

### CI Output (--ci)

```
CONSTRAINTS_CHECK=FAIL
TOTAL=5
PASSED=4
FAILED=1

FAIL:ADR-0003:backend/api.rs:45
FAIL:ADR-0003:backend/worker.rs:12
```

Exit codes:
- 0: All checks passed
- 1: Violations found
- 2: Configuration error

## Performance

The skill is optimized for speed:

1. **Parallel checks**: Independent constraints checked concurrently
2. **Scope filtering**: Only check files in constraint scope
3. **Early exit**: In CI mode, can exit on first violation
4. **Caching**: Results cached for unchanged files

## Integration

### Pre-commit Hook

```bash
#!/bin/bash
claude /constraints-check staged --ci || exit 1
```

### CI Pipeline

```yaml
- name: Architectural Constraints
  run: |
    claude /constraints-check --ci
    if [ $? -ne 0 ]; then
      echo "Architectural violations detected"
      exit 1
    fi
```

### Watch Mode (Development)

```bash
# Re-check on file changes
claude /constraints-check --watch
```
