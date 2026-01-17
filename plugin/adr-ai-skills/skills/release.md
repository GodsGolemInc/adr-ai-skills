# Skill: /release

リリースタグの作成、リリースノート生成、GitHubリリースの公開を行うスキル。

## Commands

### /release [version]
指定バージョンでリリースを作成。

```bash
/release v1.2.0        # 明示的にバージョン指定
/release patch         # パッチバージョンを自動インクリメント
/release minor         # マイナーバージョンを自動インクリメント
/release major         # メジャーバージョンを自動インクリメント
```

### /release --dry-run
実際のリリースは行わず、何が行われるかをプレビュー。

### /release notes
前回リリースからのリリースノートを生成（リリースは作成しない）。

### /release status
リリース状態を確認。

## Prerequisites

- GitHub CLI (`gh`) がインストールされていること
- mainブランチにいること
- リモートと同期済み

## Workflow

```
1. 事前チェック
   - mainブランチか確認
   - リモートと同期確認
   - 未リリースの変更があるか

2. バージョン決定
   - 前回タグを取得
   - 新バージョンを計算/検証

3. リリースノート生成
   - コミット履歴を分析
   - ADR変更を検出
   - Breaking changesを検出
   - Conventional Commits形式で分類

4. タグ作成
   - git tag -a {version}

5. GitHubリリース作成
   - gh release create

6. 結果報告
   - リリースURL
   - 次のステップ
```

## Release Notes Format

```markdown
# Release v1.2.0

## 🚀 Features
- Add user authentication (#123)
- Implement caching layer (#125)

## 🐛 Bug Fixes
- Fix memory leak in worker (#124)
- Correct timezone handling (#126)

## 📝 Documentation
- Add ADR-0015: Cache Strategy

## 🏗️ Architecture
- **New ADRs:**
  - [ADR-0015](docs/adr/0015-cache-strategy.md): Cache invalidation strategy
- **Updated Constraints:**
  - Added cache layer validation rules

## ⚠️ Breaking Changes
- `UserService.authenticate()` signature changed
  - Migration: See ADR-0012

## 📦 Dependencies
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

| コマンド | 条件 | 例 |
|----------|------|-----|
| `patch` | バグ修正のみ | v1.2.0 → v1.2.1 |
| `minor` | 新機能あり | v1.2.0 → v1.3.0 |
| `major` | Breaking changeあり | v1.2.0 → v2.0.0 |

### Conventional Commits Detection

```
feat: → minor
fix: → patch
feat!: → major (breaking)
BREAKING CHANGE: → major
```

## Implementation

### Version Calculation

```bash
# 最新タグを取得
LATEST=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# バージョン分解
MAJOR=$(echo $LATEST | cut -d. -f1 | tr -d 'v')
MINOR=$(echo $LATEST | cut -d. -f2)
PATCH=$(echo $LATEST | cut -d. -f3)

# インクリメント
case $INCREMENT in
  major) NEW="v$((MAJOR+1)).0.0" ;;
  minor) NEW="v${MAJOR}.$((MINOR+1)).0" ;;
  patch) NEW="v${MAJOR}.${MINOR}.$((PATCH+1))" ;;
esac
```

### Tag Creation

```bash
# アノテーションタグを作成
git tag -a v1.2.0 -m "Release v1.2.0

{release notes summary}"

# リモートにpush
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

### 成功時

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

### Dry-run時

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

リリースノートにADR変更を自動含める：

```markdown
## 🏗️ Architecture Decisions

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

### Breaking Change from ADR

ADRにBreaking Changeが含まれる場合：

```markdown
## ⚠️ Breaking Changes

### ADR-0012: API v2 Migration
The authentication API has been redesigned.

**Migration Guide:**
1. Update client SDK to v2.0+
2. Replace `authenticate()` with `authenticateV2()`
3. See [ADR-0012](docs/adr/0012-api-v2.md) for details
```

## Pre-release Checklist

リリース前に自動チェック：

1. **Constraints Check**: すべてのルールがパス
2. **ADR Sync**: constraints.jsonが最新
3. **Tests**: CI が緑
4. **Documentation**: 新機能のドキュメントあり
5. **Breaking Changes**: 明示的に文書化済み

## Configuration

### .release.json (optional)

```json
{
  "versionPrefix": "v",
  "branches": {
    "release": ["main", "master"],
    "prerelease": ["develop"]
  },
  "changelog": {
    "includeADR": true,
    "includeConstraints": true
  },
  "github": {
    "draft": false,
    "prerelease": false
  }
}
```
