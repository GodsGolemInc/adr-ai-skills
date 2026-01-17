# ADR AI Skills

**AI-Enhanced Architecture Decision Records** - Detect, generate, and enforce ADRs with AI.

既存のADRツール（adr-tools, MADR, log4brains）と互換性を持ちながら、AIによる設計判断の自動検出・生成・強制を実現します。

[English Documentation](./README.md)

## 従来のADRツールとの違い

| 従来のADRツール | ADR AI Skills |
|----------------|---------------|
| ADRを手動で作成 | AIが設計判断を**自動検出**して草案生成 |
| フォーマット固定 | **複数フォーマット対応**（Nygard, MADR） |
| 強制力なし | **CI連携**で制約を自動チェック |
| ワークフロー分離 | JJ/Git/PR/リリースと**統合** |

## 互換性

### サポートするフォーマット

| フォーマット | 互換ツール | インポート | エクスポート |
|-------------|-----------|:--------:|:----------:|
| Extended（拡張） | ADR AI Skills | ✓ | ✓ |
| Nygard（クラシック） | [adr-tools](https://github.com/npryce/adr-tools) | ✓ | ✓ |
| MADR | [MADR](https://github.com/adr/madr), [log4brains](https://github.com/thomvaill/log4brains) | ✓ | ✓ |

### 既存ADRからの移行

```bash
# adr-toolsのADRをインポート
/adr import docs/adr/*.md --format nygard

# MADRをインポート
/adr import docs/decisions/*.md --format madr

# Extended形式で作業後、adr-tools形式でエクスポート
/adr export --all --format nygard --output docs/adr/
```

---

## 概要

```
JJ履歴（消える）→ ADR（残る）→ constraints.json（強制される）
```

| レイヤー | 役割 | 保存先 |
|----------|------|--------|
| 試行錯誤 | 実験・失敗・やり直し | JJ (.jj) |
| 設計判断 | なぜこの設計にしたか | ADR (docs/adr/) |
| 成果物 | ビルド可能なコード | Git/GitHub |

---

## インストール

### 前提条件

```bash
# JJ (Jujutsu) - 推奨
brew install jj   # macOS
# または: cargo install jujutsu

# Claude Code
npm install -g @anthropic-ai/claude-code
```

### 方法1: プラグインとして導入（推奨）

既存プロジェクトの設定を**壊さずに**導入できます。

```bash
# 1. プラグインを取得
git clone https://github.com/GodsGolemInc/adr-ai-skills /tmp/adr-ai-skills

# 2. 既存プロジェクトにインストール
cd /path/to/your/project
/tmp/adr-ai-skills/plugin/adr-ai-skills/install.sh .

# 3. 確認
claude
> /adr list
```

#### インストーラーの動作

| 処理 | 既存ファイルがある場合 |
|------|----------------------|
| `.adr-ai-skills/` 作成 | バックアップして再作成 |
| `docs/adr/` 作成 | そのまま保持 |
| `docs/constraints.json` | 保持（上書きしない） |
| `.claude/settings.json` | **マージ**（既存設定を保持） |
| `CLAUDE.md` | **追記**（既存内容を保持） |

#### アンインストール

```bash
/tmp/adr-ai-skills/plugin/adr-ai-skills/uninstall.sh .
```

ADRやconstraintsは保持され、プラグインファイルのみ削除されます。

### 方法2: 手動導入

細かくカスタマイズしたい場合：

```bash
# 必要なディレクトリのみ作成
mkdir -p docs/adr docs/design-notes .adr-ai-skills

# 必要なファイルをコピー
cp -r plugin/adr-ai-skills/skills .adr-ai-skills/
cp -r plugin/adr-ai-skills/prompts .adr-ai-skills/
cp -r plugin/adr-ai-skills/templates .adr-ai-skills/

# CLAUDE.md に追記（手動）
# .claude/settings.json にskillsを追加（手動）
```

### 方法3: テンプレートとしてクローン（新規プロジェクト）

```bash
git clone https://github.com/GodsGolemInc/adr-ai-skills my-new-project
cd my-new-project
rm -rf .git
git init
```

---

## ディレクトリ構成

### プラグイン導入後

```
your-project/
├── .adr-ai-skills/             # プラグイン本体
│   ├── plugin.json             # プラグイン設定
│   ├── skills/                 # Claude Code Skills
│   ├── prompts/                # AIプロンプト
│   ├── templates/              # ADRテンプレート
│   └── jj-workflow.sh          # CLIヘルパー
├── .claude/
│   └── settings.json           # Skills登録（マージ済み）
├── CLAUDE.md                   # プロジェクト設定（追記済み）
├── doc/
│   ├── adr/                    # ADRドキュメント
│   ├── design-notes/           # 軽量な設計メモ
│   └── constraints.json        # 機械可読な制約
└── (your existing files...)
```

---

## 使い方

### Claude Code Skills（7スキル）

```bash
claude  # Claude Codeを起動
```

#### フェーズ1: 開発・ADR作成

| スキル | 説明 |
|--------|------|
| `/adr` | ADR管理（リスト、新規作成、インポート/エクスポート） |
| `/jj-analyze` | JJ変更からAI設計判断検出 |
| `/design-review` | AI設計コンプライアンスレビュー |
| `/constraints-check` | CI用制約チェック |

#### フェーズ2: リリース・公開

| スキル | 説明 |
|--------|------|
| `/sync` | JJ→Git同期（事前チェック付き） |
| `/pr` | PR作成（ADR自動リンク） |
| `/release` | リリースタグ＆ノート生成 |

### ADR管理 (`/adr`)

```bash
# 基本操作
/adr list              # ADR一覧
/adr new "Title"       # 新規作成
/adr extract abc123    # JJ変更からADR抽出
/adr validate          # フォーマット検証
/adr sync              # constraints.json同期

# フォーマット変換
/adr new "Title" --format nygard    # Nygard形式で作成
/adr new "Title" --format madr      # MADR形式で作成
/adr export ADR-0001 --format nygard  # エクスポート
/adr import docs/adr/*.md --format nygard  # インポート
```

### JJ変更分析 (`/jj-analyze`)

```bash
/jj-analyze abc123     # 特定の変更を分析
/jj-analyze recent     # 最近5件を分析
/jj-analyze recent 10  # 最近10件を分析
```

### 設計レビュー (`/design-review`)

```bash
/design-review abc123  # 変更をレビュー
/design-review staged  # ステージング済みをレビュー
/design-review --strict  # CI用（厳格モード）
```

### 制約チェック (`/constraints-check`)

```bash
/constraints-check           # 全体チェック
/constraints-check src/      # パス指定
/constraints-check --ci      # CI用出力
```

### Git同期 (`/sync`)

```bash
/sync                  # JJ→Git同期
/sync --dry-run        # プレビュー
/sync --skip-review    # レビュースキップ
```

### PR作成 (`/pr`)

```bash
/pr                    # PR作成（ADR自動検出）
/pr "タイトル"          # タイトル指定
/pr --draft            # ドラフトPR
```

### リリース (`/release`)

```bash
/release major         # v1.0.0 → v2.0.0
/release minor         # v1.0.0 → v1.1.0
/release patch         # v1.0.0 → v1.0.1
/release v2.1.0        # 直接指定
```

---

## ワークフロー

### 完全な開発フロー

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: Development                                        │
├─────────────────────────────────────────────────────────────┤
│  1. JJ New → 2. Implement → 3. JJ Describe                  │
│                    ↓                                         │
│  4. /jj-analyze → 5. /adr extract → 6. /design-review       │
├─────────────────────────────────────────────────────────────┤
│  Phase 2: Release                                            │
├─────────────────────────────────────────────────────────────┤
│  7. /constraints-check → 8. /sync → 9. /pr → 10. Merge      │
│                    ↓                                         │
│  11. /release → 12. Push Tags                                │
└─────────────────────────────────────────────────────────────┘
```

### スコアリングシステム

| 軸 | 質問 | 0 | 3 |
|----|------|---|---|
| Enforcement | 破ると壊れる？ | Optional | Critical |
| Scope | どこまで波及？ | 1ファイル | 全体 |
| Recurrence | 今後も出る？ | 一度きり | 毎日 |
| Rollback | 後戻り可能？ | 数分 | 全面書き直し |

| 合計 | アクション |
|------|------------|
| 10-12 | Full ADR + CI強制 |
| 7-9 | Light ADR |
| 4-6 | Design note |
| 0-3 | 不要 |

---

## CI統合

### GitHub Actions

```yaml
name: Architectural Compliance

on:
  pull_request:
    branches: [main]

jobs:
  check-constraints:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Check Constraints
        run: claude /constraints-check --ci
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

.adr-ai-skills/jj-workflow.sh validate || exit 1
claude /constraints-check staged --ci || exit 1
```

---

## トラブルシューティング

### プラグインが認識されない

```bash
# settings.jsonを確認
cat .claude/settings.json | jq '.skills'

# CLAUDE.mdを確認
grep "adr-ai-skills" CLAUDE.md
```

### 既存設定との競合

インストーラーは既存ファイルをバックアップします：

```bash
# バックアップを確認
ls -la .claude/*.backup.*
ls -la CLAUDE.md.backup.*

# 必要なら復元
cp .claude/settings.json.backup.20260117123456 .claude/settings.json
```

### JJがインストールされていない

```bash
brew install jj   # macOS
cargo install jujutsu  # その他
```

JJなしでもADR管理機能は使用可能です。

---

## 設計原則

1. **JJは消える前提** - 長期保存が必要な情報はADRへ
2. **ADRは判断を凍結** - 後から間違いと分かってもOK、新ADRで上書き
3. **constraintsは強制** - 機械可読ルールでCI検査
4. **スコアリングで節度** - 全てをADR化しない
5. **人間が最終責任** - AIは提案のみ
6. **既存環境を壊さない** - マージと追記で導入
7. **既存ツールと共存** - Nygard/MADR形式との相互変換

---

## 参考資料

- [Architecture Decision Records](https://adr.github.io/)
- [adr-tools](https://github.com/npryce/adr-tools) - Michael Nygard's ADR tooling
- [MADR](https://github.com/adr/madr) - Markdown ADRs
- [log4brains](https://github.com/thomvaill/log4brains) - ADR management with web UI
- [Jujutsu VCS](https://github.com/martinvonz/jj)
- [Claude Code](https://docs.anthropic.com/claude-code)
- [ブログ記事](./docs/blog/)

## ライセンス

MIT
