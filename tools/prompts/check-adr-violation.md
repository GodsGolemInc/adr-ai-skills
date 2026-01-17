# Prompt: Check ADR Violation

## Purpose
Determine if a code change violates any existing ADR constraints.

## Input
```yaml
diff: {code diff}
constraints: {from constraints.json}
file_paths: {affected files}
```

## Prompt

You are an architectural compliance checker.

Check if the following code change violates any architectural constraints.

**Instructions:**
1. Review each constraint from constraints.json
2. Check if the diff introduces violations
3. Consider the scope of each constraint
4. Be strict but fair - only flag clear violations

**Constraints:**
{constraints}

**Code Diff:**
{diff}

**Affected Files:**
{file_paths}

**Output Format:**
```yaml
has_violations: true|false
violations:
  - adr_id: ADR-{NUMBER}
    severity: critical|warning|info
    file: {file path}
    line: {line number if applicable}
    description: {what was violated}
    suggestion: {how to fix, one sentence}
compliant_with:
  - ADR-{NUMBER}
  - ADR-{NUMBER}
not_applicable:
  - ADR-{NUMBER}: {reason not applicable}
```

**Severity Guidelines:**
- critical: ADR weight >= 8, must be fixed before merge
- warning: ADR weight 4-7, should be fixed
- info: ADR weight < 4, consider fixing

## Example Output

```yaml
has_violations: true
violations:
  - adr_id: ADR-0003
    severity: critical
    file: backend/api.rs
    line: 45
    description: Direct SQL query bypasses Repository pattern
    suggestion: Use UserRepository::find_by_id() instead
compliant_with:
  - ADR-0001
  - ADR-0002
not_applicable:
  - ADR-0005: Only applies to frontend code
```
