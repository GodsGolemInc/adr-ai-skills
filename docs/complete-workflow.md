# Complete Development Workflow

ADR + JJ ワークフローの完全なサイクルを解説します。

## 全体像

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Phase 1: 開発サイクル（ローカル）                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┐    ┌──────────────┐    ┌─────────────┐                │
│  │ JJ作業   │───▶│ /jj-analyze  │───▶│ 設計判断？   │                │
│  └─────────┘    └──────────────┘    └──────┬──────┘                │
│                                            │                        │
│                              Yes ◀─────────┴─────────▶ No          │
│                               │                        │            │
│                               ▼                        │            │
│                      ┌────────────────┐                │            │
│                      │ /adr extract   │                │            │
│                      └───────┬────────┘                │            │
│                              │                         │            │
│                              ▼                         │            │
│                      ┌────────────────┐                │            │
│                      │ ADR承認        │                │            │
│                      └───────┬────────┘                │            │
│                              │                         │            │
│                              ▼                         ▼            │
│                      ┌────────────────┐    ┌─────────────────┐     │
│                      │ /adr sync      │───▶│ /constraints    │     │
│                      └────────────────┘    │   -check        │     │
│                                            └────────┬────────┘     │
│                                                     │              │
└─────────────────────────────────────────────────────┼──────────────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Phase 2: 公開サイクル（リモート）                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌──────────────┐     │
│  │ /sync   │───▶│ /pr     │───▶│ Review  │───▶│ Merge        │     │
│  └─────────┘    └─────────┘    └─────────┘    └──────┬───────┘     │
│                                                      │              │
│                                                      ▼              │
│                                               ┌──────────────┐      │
│                                               │ /release     │      │
│                                               └──────────────┘      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: 開発サイクル

### Step 1: JJで作業

```bash
# 新しい変更を開始
jj new -m "feat: add user authentication"

# 実装...

# 変更を記述
jj describe -m "Add Authenticator trait and JWT implementation

- Define Authenticator trait for pluggable auth
- Implement JwtAuthenticator as default
- Add tests for token validation"
```

### Step 2: 設計判断を検出

```bash
claude
> /jj-analyze recent
```

出力例：
```
## Recent Changes Analysis

| Change | Description | Decision? | Score | Action |
|--------|-------------|-----------|-------|--------|
| abc123 | Add Authenticator trait | Yes | 9 | ADR |
```

### Step 3: ADR作成（必要な場合）

```bash
> /adr extract abc123
```

AIがADR草案を生成。確認して：

```bash
> Accept
```

### Step 4: 制約を同期

```bash
> /adr sync
```

`docs/constraints.json` が更新される。

### Step 5: 制約チェック

```bash
> /constraints-check
```

すべてのルールがパスすることを確認。

---

## Phase 2: 公開サイクル

### Step 6: Git同期

```bash
> /sync
```

JJの変更がGitにエクスポートされる。

出力例：
```
## Sync Complete

JJ Change: abc123 → Git Commit: def456

### Pre-sync Check
✓ Constraints: 5/5 passed
✓ No uncommitted changes

### Next Steps
- /pr to create a pull request
```

### Step 7: PR作成

```bash
> /pr
```

出力例：
```
## Pull Request Created

PR #42: feat: Add user authentication
URL: https://github.com/org/repo/pull/42

### Related ADRs
- ADR-0005: Authenticator Trait Pattern
```

### Step 8: レビュー & マージ

GitHub上でレビュー、CIパス後にマージ。

### Step 9: リリース

```bash
> /release minor
```

出力例：
```
## Release Created

Version: v1.3.0
URL: https://github.com/org/repo/releases/tag/v1.3.0

### Highlights
- User authentication system
- ADR-0005: Authenticator Trait Pattern

### Release Notes
[自動生成されたリリースノート]
```

---

## 7つのスキル一覧

| Phase | Skill | 役割 |
|-------|-------|------|
| 1 | `/jj-analyze` | JJ変更から設計判断を検出 |
| 1 | `/adr` | ADRの作成・管理 |
| 1 | `/design-review` | 設計レビュー |
| 1 | `/constraints-check` | 制約違反のチェック |
| 2 | `/sync` | JJ → Git同期 |
| 2 | `/pr` | PR作成 |
| 2 | `/release` | タグ付け・リリース |

---

## 自動化されるもの

| 手動だったもの | 自動化 |
|--------------|-------|
| 設計判断の検出 | `/jj-analyze` |
| ADR草案作成 | `/adr extract` |
| 制約抽出 | `/adr sync` |
| 違反チェック | `/constraints-check` |
| PR説明文作成 | `/pr` |
| リリースノート | `/release` |
| ADRリンク付け | 全スキルで自動 |

---

## 人間が判断するもの

| 判断ポイント | 説明 |
|------------|------|
| ADR採用 | AIが提案したADRを採用するか |
| PR承認 | レビュー後のマージ判断 |
| リリースタイミング | いつリリースするか |
| バージョン番号 | major/minor/patch の選択 |

---

## ショートカット

### 最小ワークフロー（機能追加）

```bash
jj new && ... && jj describe -m "..."
/jj-analyze recent
/adr extract {id}  # 必要な場合
/sync
/pr
# マージ後
/release patch
```

### バグ修正（ADR不要）

```bash
jj new && ... && jj describe -m "fix: ..."
/constraints-check
/sync
/pr
# マージ後
/release patch
```

### 大きな設計変更

```bash
jj new && ...
/jj-analyze {id}
/adr new "Design Title"  # 手動で詳細に書く
/adr sync
/design-review
/sync
/pr
# マージ後
/release minor  # または major
```

---

## CI統合

### GitHub Actions

```yaml
name: ADR Workflow

on:
  pull_request:
    branches: [main]

jobs:
  constraints:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check Constraints
        run: claude /constraints-check --ci
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

  design-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Design Review
        run: claude /design-review --strict
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### リリース自動化

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    if: contains(github.event.head_commit.message, '[release]')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create Release
        run: claude /release patch
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## トラブルシューティング

### /sync が失敗する

```bash
# JJの状態を確認
jj status

# 未コミットの変更がある場合
jj squash

# 再試行
/sync
```

### /pr が失敗する

```bash
# GitHub CLIの認証確認
gh auth status

# リモートへのpush確認
git push -u origin $(git branch --show-current)

# 再試行
/pr
```

### /release が失敗する

```bash
# mainブランチにいるか確認
git branch --show-current

# リモートと同期
git pull origin main

# 再試行
/release
```

---

## まとめ

このワークフローにより：

1. **設計判断が自動検出**される
2. **ADRが自動生成**される
3. **制約が自動抽出・強制**される
4. **リリースノートが自動生成**される
5. **すべてのステップでADRがリンク**される

人間は「判断」に集中し、「作業」はAIに任せる。
