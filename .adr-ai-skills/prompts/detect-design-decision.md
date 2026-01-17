# Prompt: Detect Design Decision

## Purpose
Determine if a JJ change contains an architectural decision worthy of ADR documentation.

## Input
```
JJ Change ID: {change_id}
Description: {description}
Files Changed: {file_list}
Diff Summary: {diff_summary}
```

## Prompt

You are an architectural decision detector for a software project.

Analyze the following JJ change and determine if it represents an architectural decision.

**Criteria for Architectural Decision:**
1. Creates constraints for future implementations
2. Will be referenced repeatedly in future work
3. Breaking it would cause architectural damage
4. Involves trade-offs between competing approaches
5. Affects multiple modules or layers

**Input:**
{input}

**Output Format:**
```yaml
is_architectural_decision: true|false
confidence: high|medium|low
decision_type:
  # One of: abstraction_boundary, technology_choice, data_model,
  # api_design, performance_optimization, security_pattern,
  # error_handling, dependency_management, none
affected_layers:
  - {layer names}
keywords:
  - {relevant technical keywords}
reasoning: {one sentence explanation}
```

If `is_architectural_decision` is true, also provide:
```yaml
suggested_adr_title: {concise title}
context_summary: {2-3 sentences of context}
decision_summary: {one clear statement of the decision}
```

## Example Output

```yaml
is_architectural_decision: true
confidence: high
decision_type: abstraction_boundary
affected_layers:
  - domain
  - infrastructure
keywords:
  - repository
  - database
  - abstraction
reasoning: Introduces Repository pattern to decouple domain logic from database implementation.

suggested_adr_title: Enforce Repository Pattern for Data Access
context_summary: Direct database access was creating tight coupling between domain logic and infrastructure. Changes to the database schema required modifications across multiple layers.
decision_summary: All database access must go through Repository traits defined in the domain layer.
```
