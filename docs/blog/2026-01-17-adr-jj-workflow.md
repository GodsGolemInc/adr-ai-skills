# 設計判断を資産化する：ADR + JJ + AI ワークフローの実践

*2026-01-17*

## はじめに

「なぜこの設計にしたんだっけ？」

半年後の自分、あるいは新しくチームに加わったメンバーが、コードを前にして途方に暮れる。
Gitのログを遡っても「何を変えたか」は分かるが、「なぜそうしたか」は消えている。

この問題を解決するために、私たちは **ADR（Architecture Decision Record）+ JJ（Jujutsu）+ AI** を組み合わせたワークフローを構築しました。

本記事では、このシステムの設計思想と実装を紹介します。

---

## 問題：履歴は残るが、判断は消える

従来のバージョン管理には構造的な限界があります。

### Gitが得意なこと
- **何を**変えたか
- **いつ**変えたか
- **誰が**変えたか

### Gitが苦手なこと
- **なぜ**その設計にしたか
- どんな**代替案**を検討したか
- どんな**トレードオフ**を受け入れたか

コミットメッセージに詳細を書くこともできますが、それでは検索性が悪く、構造化もされていません。

結果として、時間とともに設計の「なぜ」は失われていきます。

---

## 解決策：3層の履歴モデル

私たちのアプローチは、履歴を3つのレイヤーに分離することです。

```
┌─────────────────────────────────────────┐
│  Layer 3: 成果物履歴（Git/GitHub）        │
│  → ビルド可能、再現可能、PRレビューに耐える  │
├─────────────────────────────────────────┤
│  Layer 2: 設計判断履歴（ADR）             │
│  → なぜ、代替案、トレードオフ              │
├─────────────────────────────────────────┤
│  Layer 1: 試行錯誤ログ（JJ）              │
│  → 実験、失敗、やり直し                   │
└─────────────────────────────────────────┘
```

### Layer 1: JJ（試行錯誤）

[JJ（Jujutsu）](https://github.com/martinvonz/jj)は次世代のバージョン管理システムです。
Gitと互換性を持ちながら、より柔軟な履歴操作が可能です。

JJの役割は「思考の精錬炉」。

```bash
jj new           # 思考単位を切る
jj describe      # 意図を言語化
jj squash        # 意味単位にまとめる
jj abandon       # 黒歴史を消す
```

重要なのは、**JJは消える前提で使う**ということ。
`.jj`ディレクトリは個人・端末依存であり、長期保存には向きません。

### Layer 2: ADR（設計判断）

ADR（Architecture Decision Record）は、設計判断を構造化して記録するフォーマットです。

```markdown
# ADR-0003: Repository Pattern導入

## Context
DB実装変更に耐える必要があった

## Decision
DBアクセスは必ずRepository Traitを経由する

## Reason
- ドメイン層とインフラ層の分離
- テスタビリティの向上
- 将来のDB変更への対応

## Consequences
- 実装が若干複雑になる
- 学習コストが発生する
```

ADRは「その時点での最善判断」を凍結するもの。
後から間違いだと分かっても**消さない**。新しいADRで上書きします。

### Layer 3: Git（成果物）

最終的にGitHub等にpushされるのは、整理された成果物だけ。
JJでの試行錯誤は見えず、ADRで判断理由が残り、コードは完成形のみ。

---

## AIの役割：判断の検出と提案

ここからが本システムの核心です。

### 人間とAIの役割分担

| フェーズ | 人間 | AI |
|----------|:----:|:--:|
| JJ change作成 | ✅ | |
| 設計判断の検出 | | ✅ |
| ADR草案の作成 | | ✅ |
| ADRの承認 | ✅ | |
| 制約違反のチェック | | ✅ |
| 最終判断 | ✅ | |

**原則：AIは判断を提案し、人間が決定する**

### 設計判断の自動検出

JJの変更履歴をAIが分析し、設計判断を検出します。

```
Input:
  JJ Change: "Add UserRepository trait, remove direct SQL usage"

AI Analysis:
  is_architectural_decision: true
  decision_type: abstraction_boundary
  suggested_adr_title: "Enforce Repository Pattern for Data Access"
```

検出の基準：
- 将来の実装に制約を与えるか
- 繰り返し参照される判断か
- 守らないと設計が崩れるか

### スコアリングによるADR乱立の防止

全ての判断をADRにすると、ノイズになります。
そこで、重要度をスコアリングして閾値を設けます。

| 軸 | 質問 | 0 | 3 |
|----|------|---|---|
| Enforcement | 破ると壊れる？ | Optional | Critical |
| Scope | どこまで波及？ | 1ファイル | 全体 |
| Recurrence | 今後も出る？ | 一度きり | 毎日 |
| Rollback | 後戻り可能？ | 数分 | 全面書き直し |

**合計スコア → アクション**

| Score | Action |
|-------|--------|
| 10-12 | Full ADR + CI強制 |
| 7-9 | ADR（CI強制なし） |
| 4-6 | Design note |
| 0-3 | ドキュメント不要 |

---

## 制約の自動強制

ADRから機械可読な制約を抽出し、CIで自動チェックします。

### constraints.json

```json
{
  "rules": [
    {
      "id": "ADR-0003",
      "description": "Direct SQL forbidden in domain layer",
      "weight": 10,
      "forbidden": ["sqlx::query!", "diesel::"],
      "scope": ["src/domain/**"],
      "checkType": "grep_forbidden"
    }
  ]
}
```

### CIでの検査

```yaml
# GitHub Actions
- name: Architectural Compliance
  run: claude /constraints-check --ci
```

違反があれば明確にフィードバック：

```
❌ ADR-0003 violation detected:
   File: src/domain/user.rs:45
   Issue: Direct SQL query bypasses Repository
   Fix: Use UserRepository::find_by_id()
```

---

## 実装：Claude Code Skills

このワークフローを実現するため、7つのAgent Skillsを実装しました。
ここでは開発フェーズの4つを紹介します（リリースフェーズの3つは[完全なワークフロー](./2026-01-17-complete-workflow.md)を参照）。

### `/adr` - ADR管理

```bash
/adr list              # 一覧表示
/adr new "Title"       # 新規作成
/adr extract abc123    # JJ変更からADR抽出
/adr sync              # constraints.json同期
```

### `/jj-analyze` - JJ変更分析

```bash
/jj-analyze abc123     # 特定の変更を分析
/jj-analyze recent     # 最近の変更を分析
```

### `/design-review` - 設計レビュー

```bash
/design-review staged  # ステージング変更をレビュー
/design-review --strict  # CI用
```

### `/constraints-check` - 制約チェック

```bash
/constraints-check     # 全体チェック
/constraints-check --ci  # CI用出力
```

---

## 日常のワークフロー

実際の開発フローはこうなります：

```
1. JJで作業
   $ jj new
   $ # 実装
   $ jj describe -m "Add UserRepository trait"

2. 設計判断の検出
   $ /jj-analyze recent
   → "Architectural decision detected (score: 10)"

3. ADR作成
   $ /adr extract abc123
   → AIがADR草案を生成
   → 人が確認して "Accept"

4. 制約同期
   $ /adr sync
   → constraints.jsonが自動更新

5. PR作成前
   $ /design-review staged
   $ /constraints-check --ci
   → 全チェックがパス

6. マージ
   → CIでも自動チェック
```

---

## 得られる効果

このシステムを導入すると：

### 1. 設計が「説明不要」になる
ADRを読めば、なぜその設計なのか分かる。
口頭での説明や考古学的コードリーディングが不要に。

### 2. 新規参加者でも破壊できない
CIが設計制約を強制するため、
知らずに設計を壊すことがなくなる。

### 3. AIが暴走しない
AIコード生成も制約に従う。
system promptにADRを読み込ませることで、
設計に沿ったコード生成が可能に。

### 4. 技術的負債が増えにくい
「なぜそうなっているか分からないコード」が減る。
変更するにも、ADRを読めば影響範囲が分かる。

---

## まとめ

**設計判断を資産化する**とは：

1. **JJで試行錯誤**し、
2. **ADRで判断を凍結**し、
3. **constraintsで強制**する

このサイクルを回すことで、
コードだけでなく「なぜそのコードなのか」も資産として残ります。

AIの時代だからこそ、
人間が下した判断を明示的に記録し、
AIにもそれを守らせる仕組みが重要になります。

---

## 次のステップ

本記事では開発フェーズを紹介しました。
リリースまでの完全なワークフローについては、以下の記事をご覧ください。

- **[7つのスキルで完結するワークフロー](./2026-01-17-complete-workflow.md)** - /sync, /pr, /release を含む完全版
- **[実践チュートリアル](./2026-01-17-getting-started-tutorial.md)** - 最初のADRを書くまで

---

## 参考リンク

- [Architecture Decision Records](https://adr.github.io/)
- [Jujutsu VCS](https://github.com/martinvonz/jj)
- [本システムのリポジトリ](https://github.com/GodsGolemInc/adr-ai-skills)

---

*このシステムは実際のプロジェクトで運用しながら改善を続けています。
フィードバックやコントリビューションを歓迎します。*
