---
name: release
description: Create release tags, generate release notes, and publish GitHub releases with ADR integration.
---

# Skill: /release

Release tag creation, release notes generation, and GitHub release publishing.

## Commands

### /release [version]
Create release with specified version.

```bash
/release v1.2.0        # Explicit version
/release patch         # Auto-increment patch
/release minor         # Auto-increment minor
/release major         # Auto-increment major
```

### /release --dry-run
Preview without creating release.

### /release notes
Generate release notes only (no release).

### /release status
Check release status.

## Prerequisites

- GitHub CLI (`gh`) installed
- On main branch
- Synced with remote

## Workflow

```
1. Pre-checks
   - On main branch?
   - Synced with remote?
   - Unreleased changes?

2. Determine version
   - Get last tag
   - Calculate/validate new version

3. Generate release notes
   - Analyze commit history
   - Detect ADR changes
   - Detect breaking changes
   - Classify by Conventional Commits

4. Create tag
   - git tag -a {version}

5. Create GitHub release
   - gh release create

6. Report results
   - Release URL
   - Next steps
```

## Release Notes Format

```markdown
# Release v1.2.0

## Features
- Add user authentication (#123)
- Implement caching layer (#125)

## Bug Fixes
- Fix memory leak in worker (#124)
- Correct timezone handling (#126)

## Documentation
- Add ADR-0015: Cache Strategy

## Architecture
- **New ADRs:**
  - [ADR-0015](docs/adr/0015-cache-strategy.md): Cache invalidation strategy
- **Updated Constraints:**
  - Added cache layer validation rules

## Breaking Changes
- `UserService.authenticate()` signature changed
  - Migration: See ADR-0012

## Dependencies
- Updated `async-runtime` to 2.0.0

---
**Full Changelog**: https://github.com/org/repo/compare/v1.1.0...v1.2.0
```

## Version Detection

### Semantic Versioning

```
v{major}.{minor}.{patch}

major: Breaking changes
minor: New features (backward compatible)
patch: Bug fixes
```

### Auto-increment Rules

| Command | Condition | Example |
|---------|-----------|---------|
| `patch` | Bug fixes only | v1.2.0 -> v1.2.1 |
| `minor` | New features | v1.2.0 -> v1.3.0 |
| `major` | Breaking changes | v1.2.0 -> v2.0.0 |

### Conventional Commits Detection

```
feat: -> minor
fix: -> patch
feat!: -> major (breaking)
BREAKING CHANGE: -> major
```

## Implementation

### Version Calculation

```bash
# Get latest tag
LATEST=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Parse version
MAJOR=$(echo $LATEST | cut -d. -f1 | tr -d 'v')
MINOR=$(echo $LATEST | cut -d. -f2)
PATCH=$(echo $LATEST | cut -d. -f3)

# Increment
case $INCREMENT in
  major) NEW="v$((MAJOR+1)).0.0" ;;
  minor) NEW="v${MAJOR}.$((MINOR+1)).0" ;;
  patch) NEW="v${MAJOR}.${MINOR}.$((PATCH+1))" ;;
esac
```

### Tag Creation

```bash
# Create annotated tag
git tag -a v1.2.0 -m "Release v1.2.0

{release notes summary}"

# Push to remote
git push origin v1.2.0
```

### GitHub Release

```bash
gh release create v1.2.0 \
  --title "Release v1.2.0" \
  --notes-file RELEASE_NOTES.md \
  --latest
```

## Output Format

### Success

```
## Release Created

**Version:** v1.2.0
**URL:** https://github.com/org/repo/releases/tag/v1.2.0

### Summary
- 3 features
- 2 bug fixes
- 1 new ADR

### Highlights
- User authentication system
- Caching layer implementation
- ADR-0015: Cache Strategy

### Architecture Changes
- New constraint: Cache validation rules

### Links
- [Full Release Notes](https://github.com/org/repo/releases/tag/v1.2.0)
- [Changelog](https://github.com/org/repo/compare/v1.1.0...v1.2.0)
```

### Dry-run

```
## Release Preview (Dry Run)

**Proposed Version:** v1.2.0
**Previous Version:** v1.1.0

### Changes Since v1.1.0
- 15 commits
- 5 PRs merged
- 2 new ADRs

### Generated Release Notes
{preview of release notes}

### Commands That Would Run
1. git tag -a v1.2.0 -m "..."
2. git push origin v1.2.0
3. gh release create v1.2.0 ...

Run `/release v1.2.0` to create this release.
```

## ADR Integration

### ADR Changes in Release

```markdown
## Architecture Decisions

### New ADRs
- [ADR-0015](docs/adr/0015-cache-strategy.md): Cache invalidation strategy
  - Weight: 9 (Important)
  - Adds constraints for cache layer

### Updated ADRs
- [ADR-0003](docs/adr/0003-repository-pattern.md): Updated scope

### New Constraints
- Cache invalidation must go through CacheService
- Direct cache access is forbidden in domain layer
```

## Pre-release Checklist

Auto-checks before release:

1. **Constraints Check**: All rules pass
2. **ADR Sync**: constraints.json is current
3. **Tests**: CI is green
4. **Documentation**: New features documented
5. **Breaking Changes**: Explicitly documented
