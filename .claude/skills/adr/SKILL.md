---
name: adr
description: ADR management - create, list, validate, export, and sync architectural decisions. Use when user mentions ADR, architecture decisions, or design documentation.
---

# Skill: /adr

ADR (Architecture Decision Record) management skill for creating, reviewing, and managing architectural decisions.

## Supported Formats

| Format | Description | Compatibility |
|--------|-------------|---------------|
| `extended` | Full format with JJ, scoring, constraints (default) | This tool |
| `nygard` | Classic format by Michael Nygard | adr-tools |
| `madr` | Markdown ADRs with options | MADR, log4brains |

## Commands

### /adr list
List all existing ADRs with their status and weight.

### /adr new [title] [--format FORMAT]
Create a new ADR from scratch or from a JJ change.

```bash
/adr new "Repository Pattern"           # Extended format (default)
/adr new "Repository Pattern" --format nygard   # Nygard format
/adr new "Repository Pattern" --format madr     # MADR format
```

### /adr extract [jj-change-id]
Analyze a JJ change and extract potential ADR if architectural decision detected.

### /adr validate
Validate all ADRs follow the template format.

### /adr sync
Synchronize constraints.json with current ADR constraints.

### /adr export [ADR-ID] --format FORMAT
Export an ADR to a different format.

```bash
/adr export ADR-0001 --format nygard    # Convert to Nygard
/adr export ADR-0001 --format madr      # Convert to MADR
/adr export --all --format nygard       # Export all
```

### /adr import [file] [--format FORMAT]
Import an ADR from another format.

```bash
/adr import docs/decisions/0001-*.md --format madr
/adr import docs/adr/0001-*.md --format nygard
```

### /adr init [--format FORMAT]
Initialize ADR structure with specified format.

```bash
/adr init                    # Extended format, docs/adr/
/adr init --format madr      # MADR format, docs/decisions/
```

## Format Details

### Extended Format (Default)

Our extended format includes:
- **Origin**: JJ change linkage for traceability
- **Decision Weight**: Scoring system (0-12)
- **Constraints**: Machine-readable rules for CI

```markdown
# ADR-0001: Title

## Origin
- JJ Change: abc123
- Date: 2026-01-17

## Decision Weight
- Total: 10

## Context
...

## Decision
...

## Constraints (Machine-Readable)
```yaml
forbidden: [...]
```
```

### Nygard Format

Classic, minimal format. Compatible with [adr-tools](https://github.com/npryce/adr-tools).

```markdown
# 1. Title

Date: 2026-01-17

## Status
Accepted

## Context
...

## Decision
...

## Consequences
...
```

### MADR Format

Structured format with options. Compatible with [MADR](https://github.com/adr/madr).

```markdown
# Title

## Context and Problem Statement
...

## Considered Options
* Option 1
* Option 2

## Decision Outcome
Chosen option: "Option 1", because ...
```

## Workflow

When user invokes /adr:

1. **Detect format**: Check existing ADRs or use default
2. **Read existing ADRs**: Scan appropriate directory
3. **Determine command**: Parse subcommand
4. **Execute**: Perform the requested operation
5. **Update constraints**: If extended format, update constraints.json

## Implementation

### /adr list

```
1. Glob docs/adr/*.md (or docs/decisions/*.md for MADR)
2. For each ADR:
   - Extract title, status, weight (if available)
   - Format as table
3. Sort by weight (descending) or number
4. Display summary
```

### /adr new [title]

```
1. Determine format (--format or detect from existing)
2. Determine next ADR number
3. If JJ available, check for recent changes
4. Present appropriate template
5. Guide user through sections
6. Write to appropriate directory
7. If extended format, offer to update constraints.json
```

### /adr extract [jj-change-id]

```
1. Get JJ change description and diff
2. Apply detect-design-decision.md prompt
3. If architectural decision detected:
   - Apply score-decision.md prompt
   - If score >= 7: Generate ADR draft
   - If score 4-6: Create design note
   - If score < 4: Report "no ADR needed"
4. Present draft for user approval
5. On approval, write files and update constraints
```

### /adr export

```
1. Read source ADR
2. Parse into intermediate structure
3. Apply format conversion mapping
4. Generate output in target format
5. Write to appropriate location
```

### /adr import

```
1. Detect source format (or use --format)
2. Parse source ADR
3. Convert to extended format
4. Add empty Origin/Weight/Constraints sections
5. Write to docs/adr/
6. Offer to fill in extended fields
```

## Conversion Mapping

### Extended -> Nygard

| Extended | Nygard |
|----------|--------|
| Context | Context |
| Decision | Decision |
| Consequences.Benefits + Trade-offs | Consequences |
| Status | Status |

**Dropped**: Origin, Decision Weight, Reason, Constraints

### Extended -> MADR

| Extended | MADR |
|----------|------|
| Context | Context and Problem Statement |
| Reason | Decision Drivers |
| Rejected Alternatives | Considered Options |
| Decision | Decision Outcome |
| Consequences | Consequences |

**Dropped**: Origin, Decision Weight, Constraints

## Output Format

### List Output

```
## ADR Summary

| ID | Title | Weight | Status | Format |
|----|-------|--------|--------|--------|
| 0001 | Repository Pattern | 10 | Accepted | extended |
| 0002 | Async Runtime | 8 | Proposed | extended |

Total: 2 ADRs (1 critical, 1 important)
Format: extended (docs/adr/)
```

### Export Output

```
## Export Complete

Exported: ADR-0001 -> docs/export/0001-repository-pattern.md
Format: nygard

Note: The following sections were dropped:
- Origin (JJ linkage)
- Decision Weight (scoring)
- Constraints (machine-readable rules)
```

## Compatibility Notes

### With adr-tools

```bash
# Initialize for adr-tools compatibility
/adr init --format nygard

# Export existing ADRs
/adr export --all --format nygard --output docs/adr/

# Then use adr-tools commands
adr new "Another Decision"
```

### With MADR / log4brains

```bash
# Initialize for MADR compatibility
/adr init --format madr

# Export to docs/decisions/
/adr export --all --format madr
```

### Bidirectional Sync

For teams using multiple tools:

```bash
# Import from adr-tools
/adr import docs/adr/*.md --format nygard

# Work with extended format
/adr new "New Decision"

# Export back for adr-tools users
/adr export --all --format nygard --output docs/adr/
```
