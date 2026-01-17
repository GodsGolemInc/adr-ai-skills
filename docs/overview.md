# ADR + JJ Development Workflow

## Core Concept

このシステムは「設計判断を資産化する」ためのワークフローです。

```
JJ履歴（消える）→ ADR（残る）→ constraints.json（強制される）
```

## 3つのレイヤー

### Layer 1: 成果物履歴（Git/GitHub）
- ビルド可能
- 再現可能
- PRレビューに耐える

### Layer 2: 設計・判断履歴（ADR）
- なぜこの設計にしたか
- 他案を捨てた理由
- トレードオフ

### Layer 3: 試行錯誤・思考ログ（JJ）
- 失敗
- やり直し
- 実験

## 重要な原則

### JJは消える前提
- `.jj` は個人・端末依存
- JJは思考を整理する道具
- JJは思考を保存する倉庫ではない

### ADRは判断を凍結する
- ADRは「その時点での最善判断」
- 後で間違っていてもOK
- 方針が変わったら新しいADRを書く
- 古いADRは消さない

### constraintsは強制する
- 機械可読なルール
- CIで自動検査
- 違反は修正必須

## スコアリングシステム

| 軸 | 質問 | 0 | 1 | 2 | 3 |
|----|------|---|---|---|---|
| Enforcement | 破ると壊れる？ | Optional | Should | Must | Critical |
| Scope | どこまで波及？ | File | Module | Layer | System |
| Recurrence | 今後も出る？ | One-time | Monthly | Weekly | Daily |
| Rollback | 後戻り可能？ | Minutes | Hours | Days | Rewrite |

### アクション閾値

| Score | Action |
|-------|--------|
| 10-12 | Full ADR + CI enforcement |
| 7-9 | Light ADR |
| 4-6 | Design note |
| 0-3 | Skip |

## 役割分担

| フェーズ | 人 | AI |
|---------|----|----|
| JJ change 作成 | ✅ | ❌ |
| 設計判断検出 | ❌ | ✅ |
| ADR草案 | ❌ | ✅ |
| ADR承認 | ✅ | ❌ |
| 実装 | ❌ | ✅ |
| 設計レビュー | ❌ | ✅ |
| 最終OK | ✅ | ❌ |

## 日常のワークフロー

### 1. 開発中（JJで作業）
```bash
jj new
# 実装
jj describe -m "Add UserRepository trait"
```

### 2. 設計判断検出
```bash
/jj-analyze recent
# AIが設計判断を検出
```

### 3. ADR作成（必要な場合）
```bash
/adr extract abc123
# AIがADR草案を生成
# 人が確認してAccept
```

### 4. 制約同期
```bash
/adr sync
# constraints.jsonが更新される
```

### 5. レビュー・CI
```bash
/design-review staged
/constraints-check --ci
```

## ファイル構成

```
.
├── CLAUDE.md                    # Claude Code設定
├── docs/
│   ├── overview.md              # このファイル
│   ├── adr/
│   │   ├── 0000-adr-process.md  # ADRプロセス定義
│   │   └── ...                  # 各ADR
│   ├── design-notes/            # 軽量な設計メモ
│   ├── constraints.json         # 機械可読な制約
│   └── constraints-schema.json  # JSONスキーマ
├── tools/
│   └── prompts/                 # AIプロンプト集
│       ├── detect-design-decision.md
│       ├── generate-adr-draft.md
│       ├── score-decision.md
│       ├── check-adr-violation.md
│       ├── review-as-architect.md
│       └── extract-constraints.md
├── skills/                      # Claude Code Skills
│   ├── adr.md
│   ├── jj-analyze.md
│   ├── design-review.md
│   └── constraints-check.md
└── templates/                   # テンプレート
    ├── adr-template.md
    └── design-note-template.md
```

## 成功の定義

このシステムが機能している状態：

1. 設計が「説明不要」になる
2. 新規参加者でも破壊できない
3. LLMが暴走しない
4. 技術的負債が増えにくい
5. 「なぜこうなったか」が消えない
