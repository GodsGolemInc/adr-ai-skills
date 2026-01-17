# Prompt: Score Design Decision

## Purpose
Calculate importance score for a design decision to determine ADR priority.

## Input
```yaml
decision_title: {title}
decision_description: {description}
affected_scope: {files/modules affected}
context: {why this decision was made}
```

## Prompt

You are evaluating the importance of an architectural decision.

Score the following decision on 4 dimensions (0-3 each).

**Decision:**
{input}

**Scoring Criteria:**

### Enforcement (0-3)
How critical is compliance?
- 0: Optional, nice-to-have
- 1: Should follow, but exceptions OK
- 2: Must follow, rare exceptions
- 3: System breaks if violated

### Scope (0-3)
How much of the codebase is affected?
- 0: Single file or function
- 1: Single module
- 2: Multiple modules or layers
- 3: Entire system

### Recurrence (0-3)
How often will developers encounter this decision?
- 0: One-time setup
- 1: Monthly
- 2: Weekly
- 3: Daily

### Rollback Cost (0-3)
How difficult is it to reverse this decision?
- 0: Trivial, minutes to change
- 1: Easy, hours of work
- 2: Moderate, days of work
- 3: Hard, requires significant rewrite

**Output Format:**
```yaml
scores:
  enforcement: {0-3}
  enforcement_reason: {one sentence}
  scope: {0-3}
  scope_reason: {one sentence}
  recurrence: {0-3}
  recurrence_reason: {one sentence}
  rollback_cost: {0-3}
  rollback_cost_reason: {one sentence}
  total: {sum 0-12}

recommendation:
  # Based on total score
  action: full_adr|light_adr|design_note|skip
  reason: {why this level of documentation}
```

**Action Thresholds:**
- 10-12: full_adr - Critical decision, requires formal ADR with CI enforcement
- 7-9: light_adr - Important decision, ADR without CI enforcement
- 4-6: design_note - Worth noting, but not ADR-worthy
- 0-3: skip - Trivial, no documentation needed

## Example Output

```yaml
scores:
  enforcement: 3
  enforcement_reason: Violating the Repository pattern would expose implementation details.
  scope: 2
  scope_reason: Affects domain and infrastructure layers.
  recurrence: 3
  recurrence_reason: Every new data access must use this pattern.
  rollback_cost: 2
  rollback_cost_reason: Would require refactoring all existing repositories.
  total: 10

recommendation:
  action: full_adr
  reason: High enforcement and recurrence scores indicate this is a foundational decision.
```
