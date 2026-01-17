# Claude Code Configuration

This repository uses an ADR (Architecture Decision Record) + JJ (Jujutsu) workflow for managing architectural decisions.

## Project Overview

This is a design workflow system that:
1. Tracks architectural decisions in ADR format
2. Integrates with JJ for change-based decision extraction
3. Enforces architectural constraints via AI and CI
4. Maintains design integrity over time

## Key Directories

- `docs/adr/` - Architecture Decision Records
- `docs/design-notes/` - Lightweight design notes (pre-ADR)
- `docs/constraints.json` - Machine-readable architectural constraints
- `tools/prompts/` - AI prompts for the workflow
- `skills/` - Claude Code skill definitions
- `templates/` - ADR and design note templates

## Skills

### /adr
ADR management - create, list, validate, and sync architectural decisions.

Usage:
- `/adr list` - Show all ADRs
- `/adr new [title]` - Create new ADR
- `/adr extract [jj-change-id]` - Extract ADR from JJ change
- `/adr validate` - Validate ADR format
- `/adr sync` - Sync constraints.json

### /jj-analyze
Analyze JJ changes for architectural significance.

Usage:
- `/jj-analyze [change-id]` - Analyze specific change
- `/jj-analyze recent [n]` - Analyze recent changes
- `/jj-analyze pending` - Show unprocessed candidates

### /design-review
Architectural compliance review.

Usage:
- `/design-review [target]` - Review changes
- `/design-review --strict` - CI mode
- `/design-review --suggest` - Include suggestions

### /constraints-check
Fast constraint validation.

Usage:
- `/constraints-check [path]` - Check path
- `/constraints-check --ci` - CI output format
- `/constraints-check --update` - Update from ADRs

## Workflow Summary

```
JJ Change → /jj-analyze → Decision Detected?
                              ↓ Yes
                         /adr extract
                              ↓
                         ADR Created
                              ↓
                         /adr sync
                              ↓
                      constraints.json
                              ↓
                     /constraints-check (CI)
```

## Design Principles

1. **ADRs are law** - Violations must be fixed or ADR must be amended
2. **JJ is ephemeral** - Don't rely on JJ history for long-term knowledge
3. **Constraints are machine-readable** - Enable automated enforcement
4. **Score before documenting** - Prevent ADR proliferation
5. **Human decides, AI proposes** - Final authority is always human

## Scoring Thresholds

| Score | Action |
|-------|--------|
| 10-12 | Full ADR with CI enforcement |
| 7-9 | ADR without CI enforcement |
| 4-6 | Design note only |
| 0-3 | No documentation needed |

## AI Prompts

Located in `tools/prompts/`:
- `detect-design-decision.md` - Identify architectural decisions
- `generate-adr-draft.md` - Create ADR from decision
- `score-decision.md` - Calculate importance score
- `check-adr-violation.md` - Validate compliance
- `review-as-architect.md` - Full architectural review
- `extract-constraints.md` - Extract machine-readable rules
