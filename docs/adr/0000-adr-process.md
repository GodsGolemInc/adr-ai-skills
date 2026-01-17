# ADR-0000: ADR Process Definition

## Origin
- JJ Change: N/A (bootstrap)
- Detected by: manual
- Date: 2026-01-17

## Decision Weight
- Enforcement: 3
- Scope: 3
- Recurrence: 3
- Rollback Cost: 2
- Total: 11

## Context
This project requires a systematic way to capture, preserve, and enforce architectural decisions. Without this, design rationale is lost over time, and both humans and AI agents may unknowingly violate established patterns.

## Decision
Adopt Architecture Decision Records (ADR) as the primary mechanism for capturing design decisions. ADRs will be:
1. Stored in `docs/adr/`
2. Numbered sequentially (0001, 0002, ...)
3. Linked to originating JJ changes when applicable
4. Scored for importance (0-12 scale)
5. Machine-readable constraints extracted to `constraints.json`

## Reason
- ADRs provide "why" context that commit messages lack
- Structured format enables AI extraction and enforcement
- Scoring prevents ADR proliferation
- JJ linkage maintains traceability

### Rejected Alternatives
- Wiki-based documentation: Not version-controlled with code
- Commit message only: Lacks structure, hard to search
- No documentation: Design knowledge lost over time

## Consequences
### Benefits
- Design decisions are preserved and searchable
- AI agents can understand and respect constraints
- New team members can understand historical context
- CI can enforce architectural rules

### Trade-offs
- Requires discipline to write ADRs
- Risk of over-documenting trivial decisions (mitigated by scoring)

## Constraints (Machine-Readable)
```yaml
required:
  - docs/adr/ directory must exist
  - ADRs must follow template format
scope:
  - entire repository
```

## Status
- [x] Accepted
