# Skill: /sync

JJ (Jujutsu) からGitへの同期を行うスキル。作業履歴を整理し、Gitにコミットする。

## Commands

### /sync
現在のJJ変更をGitに同期する（デフォルト動作）。

### /sync --squash
複数のJJ変更を1つのコミットにまとめてからGitに同期。

### /sync --dry-run
実際の同期は行わず、何が行われるかをプレビュー。

### /sync status
JJとGitの同期状態を確認。

## Prerequisites

- JJ (Jujutsu) がインストールされていること
- Gitリポジトリと共存（colocate）していること

## Workflow

```
1. JJの状態を確認
   - 未コミットの変更がないか
   - 現在のchange IDを取得

2. 設計レビューを実行
   - /constraints-check を自動実行
   - 違反があれば警告

3. 変更を整理
   - squashオプションがあれば実行
   - コミットメッセージを生成

4. Gitに同期
   - jj git export
   - bookmark を更新

5. 結果を報告
   - 同期されたコミット
   - 次のステップを提案
```

## Implementation

### /sync (default)

```bash
# 1. 状態確認
jj status
jj log -r '@' --no-graph

# 2. 制約チェック
/constraints-check

# 3. Git同期
jj git export

# 4. bookmark更新（mainブランチの場合）
jj bookmark set main -r @

# 5. 確認
git log --oneline -3
```

### /sync --squash

```bash
# 現在のブランチの変更をまとめる
jj squash

# メッセージを整理
jj describe -m "{generated message}"

# Git同期
jj git export
```

### /sync status

```bash
# JJ状態
jj status
jj log -r 'trunk()..@' --no-graph

# Git状態
git status
git log --oneline -5

# 差分確認
jj git export --dry-run 2>&1 || echo "Already in sync"
```

## Commit Message Generation

同期時のコミットメッセージは以下のルールで生成：

### 単一変更の場合
```
{JJ description}

JJ-Change: {change_id}
```

### 複数変更をsquashした場合
```
{summary of changes}

Changes included:
- {change 1 description}
- {change 2 description}

JJ-Changes: {change_id_1}, {change_id_2}
```

### ADRが関連する場合
```
{description}

Related ADRs:
- ADR-{number}: {title}

JJ-Change: {change_id}
```

## Pre-sync Checklist

同期前に自動チェック：

1. **制約チェック**: `/constraints-check` がパス
2. **未追跡ファイル**: 意図しないファイルがないか
3. **ADR同期**: 新しいADRがあればconstraints.json更新を提案
4. **ブランチ確認**: 適切なブランチにいるか

## Output Format

### 成功時

```
## Sync Complete

**JJ Change:** kkxvslpqn → **Git Commit:** abc1234

### Summary
- Files changed: 5
- Insertions: +120
- Deletions: -30

### Constraints Check
✓ All 3 rules passed

### Next Steps
- `git push origin main` to push to remote
- `/pr` to create a pull request
- `/release v1.2.0` to create a release
```

### 失敗時

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

## Integration

### With /adr
新しいADRがある場合、同期前に`/adr sync`を提案。

### With /constraints-check
同期前に自動実行。違反があればブロック。

### With /pr
同期後、PRを作成するかを提案。

### With /release
mainブランチへの同期後、リリースを提案。
