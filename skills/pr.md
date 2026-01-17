# Skill: /pr

Pull Request を作成するスキル。ADRリンク、変更サマリー、テストプランを自動生成。

## Commands

### /pr
現在のブランチからPRを作成（対話形式）。

### /pr --draft
ドラフトPRとして作成。

### /pr --title "Title" --body "Body"
タイトルとボディを指定して作成。

### /pr status
既存のPRの状態を確認。

### /pr update
既存のPRの説明を更新。

## Prerequisites

- GitHub CLI (`gh`) がインストールされていること
- GitHubにログイン済み（`gh auth status`）
- リモートにpush済み

## Workflow

```
1. 事前チェック
   - ブランチがpush済みか
   - 既存のPRがないか

2. 変更分析
   - コミット履歴を取得
   - 変更ファイルを分析
   - 関連ADRを検出

3. PR説明を生成
   - サマリー
   - 変更詳細
   - ADRリンク
   - テストプラン

4. PR作成
   - gh pr create

5. 結果報告
   - PR URL
   - 次のステップ
```

## Implementation

### PR Description Template

```markdown
## Summary
{AI生成: 変更の概要 1-3文}

## Changes
{変更内容の箇条書き}

## Related ADRs
{該当するADRがあればリンク}

## Test Plan
- [ ] {テスト項目1}
- [ ] {テスト項目2}

## Checklist
- [ ] Constraints check passed (`/constraints-check`)
- [ ] Design review completed (`/design-review`)
- [ ] ADR updated if needed

---
🤖 Generated with Claude Code
```

### ADR Detection

PR作成時、以下を自動検出：

```
1. 新規・変更されたADR
   - docs/adr/*.md の変更を検出

2. 関連するADR
   - constraints.json のルールと変更を照合
   - 影響を受けるADRをリンク

3. ADRが必要な変更
   - /jj-analyze の結果を参照
   - 未文書化の設計判断を警告
```

### Command Execution

```bash
# 1. ブランチ確認
git branch --show-current
git log origin/main..HEAD --oneline

# 2. push確認（未pushならpush）
git push -u origin $(git branch --show-current)

# 3. 変更分析
git diff origin/main...HEAD --stat

# 4. PR作成
gh pr create \
  --title "{title}" \
  --body "{body}" \
  --base main
```

## Output Format

### PR作成成功時

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

### PR更新時

```
## Pull Request Updated

**PR #123**: Updated description with ADR links

### Changes
- Added ADR-0001 reference
- Updated test plan
- Fixed typos
```

## Smart Features

### 1. ADR自動リンク

変更に関連するADRを自動検出してリンク：

```markdown
## Related ADRs
- [ADR-0003](docs/adr/0003-cache-strategy.md): This PR implements the caching strategy
- [ADR-0005](docs/adr/0005-error-handling.md): Error handling follows this pattern
```

### 2. Breaking Change検出

```markdown
## ⚠️ Breaking Changes
This PR includes breaking changes:
- API signature changed in `UserService.authenticate()`
- See ADR-0012 for migration guide
```

### 3. Design Review統合

```markdown
## Design Review
✓ Constraints check: 5/5 passed
✓ Design review: Approved by /design-review

### Verified ADRs
- ADR-0001: Compliant
- ADR-0003: Compliant
```

## Configuration

### Labels

PRに自動でラベルを付与：

| 条件 | ラベル |
|------|--------|
| 新規ADRあり | `adr` |
| constraintsに影響 | `architecture` |
| ドキュメントのみ | `docs` |
| テストのみ | `tests` |

### Reviewers

`CODEOWNERS`や設定に基づいて自動でレビュアーを追加：

```bash
gh pr create --reviewer @architect-team
```

## Integration

### With /sync
同期後にPR作成を提案。

### With /design-review
PR作成前にデザインレビューを実行。

### With /release
マージ後にリリース作成を提案。
