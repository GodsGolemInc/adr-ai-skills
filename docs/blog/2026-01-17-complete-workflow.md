# 開発からリリースまで：7つのスキルで完結するADR + JJワークフロー

*2026-01-17*

## はじめに

[前回の記事](./2026-01-17-adr-jj-workflow.md)では、ADR + JJ + AIを組み合わせた設計判断の資産化について紹介しました。

しかし、そこには1つ欠けていたピースがありました。

**「設計判断を記録した後、どうやってリリースするのか？」**

今回は、開発からリリースまでを完全にカバーする7つのスキルと、その連携について解説します。

---

## 課題：2つの断絶

従来のワークフローには2つの断絶がありました。

### 断絶1: 設計判断 ↔ コード

```
コードを書く → コミット → PR → マージ
         ↑
     設計判断はどこ？
```

設計判断がコードと分離していて、後から追えない。

### 断絶2: 開発 ↔ リリース

```
開発完了 → ??? → タグ付け → リリースノート → 公開
              ↑
          手作業の壁
```

リリースプロセスが手作業で、ADRとの連携がない。

---

## 解決：2フェーズ・7スキル

この2つの断絶を埋めるため、ワークフローを2つのフェーズに分け、7つのスキルで完結させます。

```
┌─────────────────────────────────────────────────────┐
│  Phase 1: 開発サイクル（ローカル）                    │
│                                                     │
│  JJ → /jj-analyze → /adr → /design-review          │
│                   → /constraints-check              │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│  Phase 2: 公開サイクル（リモート）                    │
│                                                     │
│  /sync → /pr → Review → Merge → /release           │
└─────────────────────────────────────────────────────┘
```

---

## 7つのスキル

### Phase 1: 開発サイクル

| Skill | 役割 |
|-------|------|
| `/jj-analyze` | JJ変更から設計判断を検出 |
| `/adr` | ADRの作成・管理・同期 |
| `/design-review` | 設計レビュー |
| `/constraints-check` | 制約違反のチェック |

### Phase 2: 公開サイクル

| Skill | 役割 |
|-------|------|
| `/sync` | JJ → Git同期 |
| `/pr` | PR作成（ADRリンク付き） |
| `/release` | タグ付け・リリース |

---

## Phase 2の詳細：公開サイクル

### /sync - JJからGitへ

JJでの作業をGitに同期します。

```bash
> /sync
```

**自動で行われること：**

1. 制約チェック（`/constraints-check`）
2. JJ変更のsquash（オプション）
3. Gitへのエクスポート
4. bookmark（ブランチ）の更新

**出力例：**

```
## Sync Complete

JJ Change: kkxvslpqn → Git Commit: abc1234

### Pre-sync Check
✓ Constraints: 5/5 passed
✓ No uncommitted changes

### Summary
- Files changed: 8
- Insertions: +250
- Deletions: -50

### Next Steps
- /pr to create a pull request
```

**ポイント：**
- 同期前に制約チェックが自動実行
- 違反があればブロック
- ADRと連動してコミットメッセージを生成

---

### /pr - PRの作成

GitHub PRを作成します。ADRリンク付き。

```bash
> /pr
```

**自動で行われること：**

1. 変更分析（コミット履歴、ファイル）
2. 関連ADRの検出
3. PR説明文の生成
4. `gh pr create` の実行

**生成されるPR説明文：**

```markdown
## Summary
Added Authenticator trait pattern for pluggable authentication.

## Changes
- Define Authenticator trait for pluggable auth
- Implement JwtAuthenticator as default
- Add unit tests for token validation

## Related ADRs
- [ADR-0005: Authenticator Trait Pattern](docs/adr/0005-authenticator-trait.md)

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual verification of JWT flow

---
🤖 Generated with Claude Code
```

**ポイント：**
- 関連ADRが自動でリンクされる
- Breaking Changeが検出される
- テストプランが自動提案される

---

### /release - リリース作成

タグ付けとGitHubリリースを作成します。

```bash
> /release v1.3.0
# または
> /release minor    # 自動インクリメント
```

**自動で行われること：**

1. バージョン計算（指定 or 自動）
2. リリースノート生成
3. Gitタグ作成
4. GitHubリリース作成

**生成されるリリースノート：**

```markdown
# Release v1.3.0

## 🚀 Features
- Add user authentication (#42)
- Implement caching layer (#45)

## 🐛 Bug Fixes
- Fix memory leak in worker (#43)

## 🏗️ Architecture
- **New ADRs:**
  - [ADR-0005](docs/adr/0005-authenticator-trait.md): Authenticator trait pattern
  - [ADR-0006](docs/adr/0006-cache-strategy.md): Cache invalidation strategy

## ⚠️ Breaking Changes
- `UserService.authenticate()` signature changed
  - See ADR-0005 for migration guide

---
**Full Changelog**: compare/v1.2.0...v1.3.0
```

**ポイント：**
- ADR変更がリリースノートに含まれる
- Breaking Changeが自動検出される
- Conventional Commitsに対応

---

## 実際のワークフロー例

### 機能追加の例

```bash
# 1. JJで作業
$ jj new -m "feat: add user authentication"
$ # 実装...
$ jj describe -m "Add Authenticator trait and JWT implementation"

# 2. Claude Codeで分析
$ claude
> /jj-analyze recent
# → "ADR候補を検出"

# 3. ADR作成
> /adr extract abc123
# → ADR草案が生成される
> Accept

# 4. 制約同期 & チェック
> /adr sync
> /constraints-check
# → すべてパス

# 5. Git同期
> /sync
# → JJ → Git同期完了

# 6. PR作成
> /pr
# → PR #42 作成、ADR-0005がリンク

# 7. （GitHub上でレビュー、マージ）

# 8. リリース
> /release minor
# → v1.3.0 リリース、ADR変更がノートに含まれる
```

### バグ修正の例（ADR不要）

```bash
$ jj new -m "fix: memory leak in worker"
$ # 修正...

$ claude
> /jj-analyze recent
# → "設計判断なし"

> /constraints-check
# → パス

> /sync
> /pr
# マージ後
> /release patch
# → v1.3.1
```

---

## ADRがすべてを貫く

このワークフローの特徴は、**ADRがすべてのステップに現れる**ことです。

| ステップ | ADRとの連携 |
|----------|------------|
| `/jj-analyze` | ADR候補を検出 |
| `/adr extract` | ADRを生成 |
| `/adr sync` | 制約を抽出 |
| `/constraints-check` | ADR違反を検出 |
| `/sync` | ADR関連のコミットメッセージ |
| `/pr` | 関連ADRをリンク |
| `/release` | ADR変更をリリースノートに含む |

---

## 自動化 vs 人間の判断

### AIが自動化するもの

- 設計判断の**検出**
- ADR草案の**生成**
- 制約の**抽出**
- 違反の**チェック**
- PR説明文の**作成**
- リリースノートの**生成**

### 人間が判断するもの

- ADRを**採用するか**
- PRを**マージするか**
- **いつ**リリースするか
- バージョン番号（major/minor/patch）

**原則：AIは提案し、人間が決定する**

---

## まとめ

7つのスキルにより：

1. **開発からリリースまで**が1つのワークフローに
2. **設計判断が自動で追跡**される
3. **リリースノートにADRが含まれる**
4. **手作業が最小化**される

設計判断を記録して終わりではなく、それをリリースまで**一貫して活用**する。

これが、ADR + JJワークフローの完成形です。

---

## 次のステップ

- [実践チュートリアル](./2026-01-17-getting-started-tutorial.md)
- [完全なワークフロー図](../complete-workflow.md)
- [CI/CD統合ガイド](#)（準備中）

---

*フィードバックやコントリビューションを歓迎します。*
