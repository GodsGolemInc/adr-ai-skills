# 実践チュートリアル：最初のADRを書くまで

*2026-01-17*

前回の記事では、ADR + JJ + AIワークフローの全体像を紹介しました。
本記事では、実際に手を動かして最初のADRを作成するまでの流れを解説します。

---

## 前提条件

以下がインストールされていることを確認してください：

```bash
# JJ (Jujutsu) - 推奨
jj --version
# jj 0.x.x

# Claude Code
claude --version
# Claude Code v1.x.x
```

## Step 1: プロジェクトのセットアップ

### 1.1 ワークフローシステムの導入

```bash
# 既存プロジェクトにワークフローを追加
cd your-project

# ディレクトリ構造を作成
# プラグインインストーラーを使用
git clone https://github.com/GodsGolemInc/adr-ai-skills /tmp/adr-ai-skills
/tmp/adr-ai-skills/plugin/adr-ai-skills/install.sh .
```

### 1.2 JJの初期化（オプション）

```bash
# Gitリポジトリと共存可能
jj git init --colocate

# 現在の状態を確認
jj status
```

### 1.3 検証

```bash
claude
> /adr list
```

期待される出力：
```
## ADR Summary

| ID | Title | Weight | Status |
|----|-------|--------|--------|
| 0000 | ADR Process Adopted | 11 | Accepted |

Total: 1 ADR
```

---

## Step 2: 開発作業をJJで行う

実際の開発シナリオを想定して進めます。

### 2.1 新しい変更を開始

```bash
jj new -m "Implement user authentication"
```

### 2.2 コードを実装

ここでは、認証機能を追加する例を考えます。

```rust
// src/auth/mod.rs
pub trait Authenticator {
    fn authenticate(&self, token: &str) -> Result<User, AuthError>;
}

pub struct JwtAuthenticator {
    secret: String,
}

impl Authenticator for JwtAuthenticator {
    fn authenticate(&self, token: &str) -> Result<User, AuthError> {
        // JWT検証ロジック
    }
}
```

### 2.3 変更を記述

```bash
jj describe -m "Add Authenticator trait and JWT implementation

- Define Authenticator trait for pluggable auth
- Implement JwtAuthenticator as default
- Separate interface from implementation"
```

---

## Step 3: 設計判断を検出する

### 3.1 JJ変更を分析

Claude Codeを起動して、変更を分析します。

```bash
claude
```

```
> /jj-analyze recent
```

AIが変更を分析し、以下のような結果を返します：

```
## JJ Change Analysis

**Change:** kkxvslpqn
**Description:** Add Authenticator trait and JWT implementation

### Architectural Assessment
- **Is Decision:** Yes
- **Confidence:** High
- **Type:** abstraction_boundary

### Score Preview
| Dimension    | Score | Reason                              |
|--------------|-------|-------------------------------------|
| Enforcement  | 2     | Auth must go through trait          |
| Scope        | 2     | Affects all authenticated endpoints |
| Recurrence   | 3     | Every new auth method needs this    |
| Rollback     | 2     | Would require refactoring all uses  |
| **Total**    | **9** |                                     |

### Recommendation
**Action:** ADR (light)
**Reason:** High recurrence score indicates ongoing relevance.

[Create ADR] [Create Design Note] [Skip]
```

スコア9なので、ADR作成が推奨されています。

---

## Step 4: ADRを作成する

### 4.1 ADR抽出を実行

```
> /adr extract kkxvslpqn
```

AIがADR草案を生成します：

```markdown
# ADR-0001: Authenticator Trait Pattern

## Origin
- JJ Change: kkxvslpqn
- Detected by: adr-extractor
- Date: 2026-01-17

## Decision Weight
- Enforcement: 2
- Scope: 2
- Recurrence: 3
- Rollback Cost: 2
- Total: 9

## Context
認証機能の実装にあたり、将来的に複数の認証方式
（JWT、OAuth、API Key等）をサポートする必要があった。
直接的なJWT実装では、認証方式の切り替えが困難になる。

## Decision
認証は必ず `Authenticator` traitを経由する。
具体的な認証実装（JWT、OAuth等）はこのtraitを実装する。

## Reason
- 認証方式の差し替えが容易
- テスト時にモック認証が使える
- 新しい認証方式の追加が既存コードに影響しない

### Rejected Alternatives
- 直接JWT実装: 将来の拡張が困難
- enum による方式切り替え: 新方式追加時に全箇所修正が必要

## Consequences
### Benefits
- 認証方式の変更が1箇所で完結
- 単体テストが書きやすい

### Trade-offs
- trait定義の学習コスト
- 間接参照によるわずかなオーバーヘッド

## Constraints (Machine-Readable)
```yaml
required:
  - "impl Authenticator"
  - "dyn Authenticator"
forbidden:
  - "JwtAuthenticator::authenticate"  # 直接呼び出し禁止
scope:
  - "src/**"
exceptions:
  - "src/auth/mod.rs"  # 実装ファイル自体は例外
```

## Status
- [x] Proposed
- [ ] Accepted
```

### 4.2 草案を確認・修正

生成された草案を確認します。

```
> この草案で良いですか？修正が必要な点があれば教えてください。
```

問題なければ：

```
> Accept
```

ADRが `docs/adr/0001-authenticator-trait-pattern.md` に保存されます。

---

## Step 5: 制約を同期する

### 5.1 constraints.json を更新

```
> /adr sync
```

`docs/constraints.json` が更新されます：

```json
{
  "rules": [
    {
      "id": "ADR-0001",
      "description": "Auth must use Authenticator trait",
      "weight": 9,
      "enforcement": "required",
      "required": ["impl Authenticator", "dyn Authenticator"],
      "forbidden": ["JwtAuthenticator::authenticate"],
      "scope": ["src/**"],
      "exceptions": ["src/auth/mod.rs"],
      "checkType": "grep_forbidden"
    }
  ]
}
```

---

## Step 6: 制約をチェックする

### 6.1 現在のコードをチェック

```
> /constraints-check
```

```
## Constraints Check

**Total Rules:** 1
**Passed:** 1
**Failed:** 0

| ADR      | Rule                          | Status |
|----------|-------------------------------|--------|
| ADR-0001 | Auth must use Authenticator   | PASS   |
```

### 6.2 違反を試す（実験）

試しに、直接呼び出しを追加してみます：

```rust
// src/api/handler.rs
fn handle_request(token: &str) {
    let auth = JwtAuthenticator::new(secret);
    let user = auth.authenticate(token)?;  // 直接呼び出し！
}
```

再度チェック：

```
> /constraints-check
```

```
## Constraints Check

**Failed:** 1

### Failures

**ADR-0001: Auth must use Authenticator trait** (Weight: 9)
- File: src/api/handler.rs
- Line: 4
- Issue: Direct call to JwtAuthenticator::authenticate
- Fix: Inject Authenticator trait object instead
```

---

## Step 7: Gitに同期

### 7.1 /sync でGitへ

```
> /sync
```

出力例：
```
## Sync Complete

JJ Change: abc123 → Git Commit: def456

### Pre-sync Check
✓ Constraints: 1/1 passed

### Next Steps
- /pr to create a pull request
```

### 7.2 PRを作成

```
> /pr
```

ADRが自動でリンクされます：

```
## Pull Request Created

PR #1: feat: Add Authenticator trait pattern
URL: https://github.com/org/repo/pull/1

### Related ADRs
- ADR-0001: Authenticator Trait Pattern
```

### 7.3 マージ後のリリース（オプション）

```
> /release patch
```

リリースノートにADR変更が含まれます。

---

## まとめ：ワークフロー全体図

```
Phase 1: 開発サイクル
┌──────────────────┐
│ 1. jj new        │ ← 作業開始
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 2. 実装          │ ← コードを書く
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 3. jj describe   │ ← 意図を記述
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 4. /jj-analyze   │ ← AIが設計判断を検出
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 5. /adr extract  │ ← ADR草案生成
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 6. Accept/Reject │ ← 人が判断
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 7. /adr sync     │ ← 制約を同期
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 8. /constraints  │ ← 違反チェック
│    -check        │
└────────┬─────────┘
         │
Phase 2: 公開サイクル
         ▼
┌──────────────────┐
│ 9. /sync         │ ← JJ → Git同期
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 10. /pr          │ ← PR作成
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 11. Review/Merge │ ← GitHub上
└────────┬─────────┘
         ▼
┌──────────────────┐
│ 12. /release     │ ← リリース
└──────────────────┘
```

---

## 次のステップ

- **[7つのスキルで完結するワークフロー](./2026-01-17-complete-workflow.md)** - /sync, /pr, /release の詳細
- **[設計判断を資産化する](./2026-01-17-adr-jj-workflow.md)** - 概念と設計思想

---

*質問やフィードバックは、GitHubのIssueまたはDiscussionsでお待ちしています。*
