# Skill: /jj-analyze

Analyze JJ (Jujutsu) changes to detect architectural decisions and manage the JJ → ADR pipeline.

## Commands

### /jj-analyze [change-id]
Analyze a specific JJ change for architectural significance.

### /jj-analyze recent [n]
Analyze the N most recent JJ changes (default: 5).

### /jj-analyze pending
Show changes that were flagged as potential ADRs but not yet processed.

## Prerequisites

This skill requires JJ (Jujutsu) to be installed and the repository to be a JJ workspace.

Check with: `jj --version`

## Workflow

### Single Change Analysis

```
1. Run: jj show {change-id} --summary
2. Run: jj diff -r {change-id}
3. Extract:
   - Change description
   - Files modified
   - Diff content
4. Apply detect-design-decision.md prompt
5. If architectural decision detected:
   - Apply score-decision.md
   - Present findings
   - Offer to create ADR
```

### Batch Analysis

```
1. Run: jj log -r 'heads(trunk())..@' --limit {n}
2. For each change:
   - Quick analysis for architectural signals
   - Flag potential decisions
3. Present summary table
4. Allow drill-down into specific changes
```

## Detection Signals

The skill looks for these indicators of architectural decisions:

**High Confidence:**
- New trait/interface definitions
- New module boundaries
- Dependency changes (Cargo.toml, package.json)
- Configuration structure changes
- Error handling patterns

**Medium Confidence:**
- Refactoring across multiple files
- New abstraction layers
- Performance-related changes

**Low Confidence:**
- Single file changes
- Test additions
- Documentation updates

## Output Format

### Single Change Result

```
## JJ Change Analysis: {change-id}

**Description:** {description}
**Files:** {count} files changed

### Architectural Assessment
- **Is Decision:** Yes/No
- **Confidence:** High/Medium/Low
- **Type:** {decision_type}

### Score Preview
| Dimension | Score | Reason |
|-----------|-------|--------|
| Enforcement | 3 | {reason} |
| Scope | 2 | {reason} |
| Recurrence | 3 | {reason} |
| Rollback | 2 | {reason} |
| **Total** | **10** | |

### Recommendation
{action}: {reason}

[Create ADR] [Create Design Note] [Skip]
```

### Batch Analysis Result

```
## Recent Changes Analysis

| Change | Description | Decision? | Score | Action |
|--------|-------------|-----------|-------|--------|
| abc123 | Add Repository | Yes | 10 | ADR |
| def456 | Fix typo | No | - | Skip |
| ghi789 | Refactor utils | Maybe | 5 | Note |

**Summary:** 1 ADR candidate, 1 design note candidate, 1 skip
```

## Integration with /adr

When a change is identified as ADR-worthy:

```
1. User confirms
2. Invoke /adr extract {change-id}
3. ADR draft generated with JJ change linked in Origin
```
