---
name: sync
description: Sync JJ (Jujutsu) changes to Git with pre-sync checks. Use when synchronizing JJ work to Git.
---

# Skill: /sync

JJ (Jujutsu) to Git synchronization with pre-sync validation.

## Commands

### /sync
Sync current JJ changes to Git (default).

### /sync --squash
Squash multiple JJ changes into one commit before syncing.

### /sync --dry-run
Preview what would happen without actual sync.

### /sync status
Check JJ and Git sync status.

## Prerequisites

- JJ (Jujutsu) installed
- Repository in colocated mode (JJ + Git)

## Workflow

```
1. Check JJ status
   - Uncommitted changes?
   - Get current change ID

2. Run design review
   - Auto-run /constraints-check
   - Warn on violations

3. Organize changes
   - Apply squash if requested
   - Generate commit message

4. Sync to Git
   - jj git export
   - Update bookmark

5. Report results
   - Synced commits
   - Suggest next steps
```

## Implementation

### /sync (default)

```bash
# 1. Status check
jj status
jj log -r '@' --no-graph

# 2. Constraints check
/constraints-check

# 3. Git sync
jj git export

# 4. Update bookmark (if on main)
jj bookmark set main -r @

# 5. Verify
git log --oneline -3
```

### /sync --squash

```bash
# Squash current branch changes
jj squash

# Clean up message
jj describe -m "{generated message}"

# Git sync
jj git export
```

### /sync status

```bash
# JJ status
jj status
jj log -r 'trunk()..@' --no-graph

# Git status
git status
git log --oneline -5

# Diff check
jj git export --dry-run 2>&1 || echo "Already in sync"
```

## Commit Message Generation

### Single change
```
{JJ description}

JJ-Change: {change_id}
```

### Squashed changes
```
{summary of changes}

Changes included:
- {change 1 description}
- {change 2 description}

JJ-Changes: {change_id_1}, {change_id_2}
```

### With related ADRs
```
{description}

Related ADRs:
- ADR-{number}: {title}

JJ-Change: {change_id}
```

## Output Format

### Success

```
## Sync Complete

**JJ Change:** kkxvslpqn -> **Git Commit:** abc1234

### Summary
- Files changed: 5
- Insertions: +120
- Deletions: -30

### Constraints Check
All 3 rules passed

### Next Steps
- `git push origin main` to push to remote
- `/pr` to create a pull request
- `/release v1.2.0` to create a release
```

### Blocked

```
## Sync Blocked

### Issues Found

1. **Constraint Violation**
   - ADR-0003: tokio usage in backend/api.rs
   - Fix required before sync

2. **Uncommitted Changes**
   - src/lib.rs has uncommitted changes
   - Run `jj commit` or `jj squash` first

### Actions
- Fix issues and run `/sync` again
- Use `/sync --force` to override (not recommended)
```
