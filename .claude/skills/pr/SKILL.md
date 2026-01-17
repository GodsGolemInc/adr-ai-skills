---
name: pr
description: Create Pull Requests with auto-generated ADR links, summaries, and test plans. Use when creating PRs.
---

# Skill: /pr

Pull Request creation with ADR links, change summary, and test plan generation.

## Commands

### /pr
Create PR from current branch (interactive).

### /pr --draft
Create as draft PR.

### /pr --title "Title" --body "Body"
Create with specified title and body.

### /pr status
Check existing PR status.

### /pr update
Update existing PR description.

## Prerequisites

- GitHub CLI (`gh`) installed
- Logged in (`gh auth status`)
- Pushed to remote

## Workflow

```
1. Pre-checks
   - Branch pushed?
   - Existing PR?

2. Analyze changes
   - Get commit history
   - Analyze changed files
   - Detect related ADRs

3. Generate PR description
   - Summary
   - Change details
   - ADR links
   - Test plan

4. Create PR
   - gh pr create

5. Report results
   - PR URL
   - Next steps
```

## PR Description Template

```markdown
## Summary
{AI-generated: 1-3 sentence overview}

## Changes
{Bullet list of changes}

## Related ADRs
{Links to relevant ADRs}

## Test Plan
- [ ] {Test item 1}
- [ ] {Test item 2}

## Checklist
- [ ] Constraints check passed (`/constraints-check`)
- [ ] Design review completed (`/design-review`)
- [ ] ADR updated if needed

---
Generated with Claude Code
```

## ADR Detection

Auto-detect related ADRs:

```
1. New/changed ADRs
   - Detect changes in docs/adr/*.md

2. Related ADRs
   - Match constraints.json rules to changes
   - Link affected ADRs

3. Missing ADRs
   - Reference /jj-analyze results
   - Warn about undocumented decisions
```

## Command Execution

```bash
# 1. Check branch
git branch --show-current
git log origin/main..HEAD --oneline

# 2. Push if needed
git push -u origin $(git branch --show-current)

# 3. Analyze changes
git diff origin/main...HEAD --stat

# 4. Create PR
gh pr create \
  --title "{title}" \
  --body "{body}" \
  --base main
```

## Output Format

### PR Created

```
## Pull Request Created

**PR #123**: feat: Add user authentication
**URL**: https://github.com/org/repo/pull/123

### Summary
Added Authenticator trait pattern for pluggable authentication.

### Related ADRs
- [ADR-0001: Authenticator Trait Pattern](docs/adr/0001-authenticator-trait-pattern.md)

### Status
- Branch: `feature/auth`
- Base: `main`
- Commits: 3
- Files changed: 8

### Next Steps
- Request review: `gh pr review 123 --request`
- Check CI status: `gh pr checks 123`
- After merge: `/release` to tag a new version
```

## Smart Features

### 1. ADR Auto-linking

```markdown
## Related ADRs
- [ADR-0003](docs/adr/0003-cache-strategy.md): This PR implements the caching strategy
- [ADR-0005](docs/adr/0005-error-handling.md): Error handling follows this pattern
```

### 2. Breaking Change Detection

```markdown
## Breaking Changes
This PR includes breaking changes:
- API signature changed in `UserService.authenticate()`
- See ADR-0012 for migration guide
```

### 3. Design Review Integration

```markdown
## Design Review
Constraints check: 5/5 passed
Design review: Approved by /design-review

### Verified ADRs
- ADR-0001: Compliant
- ADR-0003: Compliant
```

## Auto Labels

| Condition | Label |
|-----------|-------|
| New ADR | `adr` |
| Affects constraints | `architecture` |
| Docs only | `docs` |
| Tests only | `tests` |
