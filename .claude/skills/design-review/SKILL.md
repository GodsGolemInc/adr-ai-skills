---
name: design-review
description: Architectural review that checks code changes against established ADRs and design principles. Use for compliance checking.
---

# Skill: /design-review

Architectural review skill that checks code changes against established ADRs and design principles.

## Commands

### /design-review [target]
Review code changes for architectural compliance.

Target can be:
- JJ change ID
- File path
- `staged` (for git staged changes)
- `pr` (for current PR)

### /design-review --strict
Fail on any ADR violation (for CI usage).

### /design-review --suggest
Include improvement suggestions beyond compliance.

## Workflow

```
1. Load constraints from docs/constraints.json
2. Load ADR summaries from docs/adr/
3. Get diff for target
4. For each constraint:
   - Check if scope applies
   - Run appropriate check
5. Apply review-as-architect.md prompt
6. Generate report
```

## Review Dimensions

### 1. ADR Compliance
Check that changes don't violate existing architectural decisions.

```yaml
Check:
  - Forbidden patterns not introduced
  - Required patterns maintained
  - Scope boundaries respected
Output:
  - PASS: All constraints satisfied
  - FAIL: Specific violations listed
```

### 2. Design Consistency
Evaluate if changes follow established patterns.

```yaml
Check:
  - Similar code follows similar patterns
  - Naming conventions respected
  - Layer boundaries maintained
Output:
  - Consistent / Inconsistent with examples
```

### 3. New Decision Detection
Identify if changes introduce new architectural decisions.

```yaml
Check:
  - New abstractions introduced
  - New dependencies added
  - New patterns established
Output:
  - Potential ADR needed: Yes/No
```

## Output Format

### Standard Review

```
## Design Review: {target}

### ADR Compliance
| ADR | Status | Details |
|-----|--------|---------|
| ADR-0001 | PASS | - |
| ADR-0003 | FAIL | tokio usage in backend/api.rs:45 |

### Violations (1)

**ADR-0003: No tokio in backend** (Weight: 10)
- File: backend/api.rs
- Line: 45
- Issue: Direct tokio::spawn() call
- Fix: Use the async runtime abstraction from core::runtime

### Design Observations
- Pattern consistency: OK
- Layer separation: OK
- Error handling: Minor concern (line 78 swallows error)

### New Decisions Detected
- None

### Verdict: NEEDS CHANGES
Fix ADR-0003 violation before merge.
```

### Strict Mode (CI)

```
DESIGN_REVIEW_RESULT=FAIL
VIOLATIONS=1
CRITICAL=1
WARNINGS=0

ADR-0003:backend/api.rs:45:tokio usage forbidden
```

## Integration Points

### With /jj-analyze
After analyzing a change, offer design review.

### With /adr
When new decision detected, offer to create ADR.

### With CI
Can be invoked in CI pipeline:
```yaml
- name: Design Review
  run: claude /design-review staged --strict
```
