# Prompt: Generate ADR Draft

## Purpose
Generate a complete ADR draft from a detected design decision.

## Input
```yaml
jj_change_id: {id}
suggested_title: {title}
context_summary: {context}
decision_summary: {decision}
affected_layers: {layers}
keywords: {keywords}
diff_content: {optional diff for context}
```

## Prompt

You are an ADR (Architecture Decision Record) writer.

Generate a complete ADR document from the following design decision information.

**Requirements:**
1. Follow the standard ADR template exactly
2. Be concise but complete
3. Focus on "why" over "what"
4. Include at least 2 rejected alternatives with reasons
5. Be honest about trade-offs
6. Make constraints machine-parseable

**Input:**
{input}

**Output Format:**
Generate a complete ADR in markdown following this structure:

```markdown
# ADR-{NUMBER}: {TITLE}

## Origin
- JJ Change: {jj_change_id}
- Detected by: adr-extractor
- Date: {today}

## Decision Weight
- Enforcement: {0-3}
- Scope: {0-3}
- Recurrence: {0-3}
- Rollback Cost: {0-3}
- Total: {sum}

## Context
{2-4 sentences explaining the problem and constraints}

## Decision
{One clear statement of what was decided}

## Reason
{Why this choice?}
- {Reason 1}
- {Reason 2}

### Rejected Alternatives
- {Alternative 1}: {Why rejected in one sentence}
- {Alternative 2}: {Why rejected in one sentence}

## Consequences
### Benefits
- {Benefit 1}
- {Benefit 2}

### Trade-offs
- {Trade-off 1}
- {Trade-off 2}

## Constraints (Machine-Readable)
```yaml
forbidden:
  - {if applicable}
required:
  - {if applicable}
scope:
  - {affected directories}
```

## Status
- [x] Proposed
- [ ] Accepted
- [ ] Deprecated
```

**Scoring Guidelines:**
- Enforcement (0-3): How critical is compliance? 3 = system breaks if violated
- Scope (0-3): How much code is affected? 3 = entire system
- Recurrence (0-3): How often will this decision be relevant? 3 = daily
- Rollback Cost (0-3): How hard to undo? 3 = requires full rewrite
