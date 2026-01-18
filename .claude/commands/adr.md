---
description: ADR management - create, list, validate, export, and sync architectural decisions
---

# /adr Command

Execute the ADR (Architecture Decision Record) management skill.

## Usage
- `/adr list` - List all ADRs
- `/adr new [title]` - Create new ADR
- `/adr extract [jj-change-id]` - Extract ADR from JJ change
- `/adr validate` - Validate ADR format
- `/adr sync` - Sync constraints.json
- `/adr export [ADR-ID] --format [nygard|madr]` - Export to other format
- `/adr import [file] --format [nygard|madr]` - Import from other format

## Request
$ARGUMENTS
