# claude-dev-agents

[English](./README.md) | [한국어](./README.ko.md)

Claude Code の `~/.claude/agents` + `rules` を git で管理し、マシン間同期・チームメンバーへの配布を実現します。

## このリポジトリの役割

| 変更前 | 変更後 |
|---|---|
| agents/rules が `~/.claude/` にのみ存在 | git リポジトリがソースオブトゥルース、コピーでインストール |
| 別マシンへ手動コピー | `git pull && ./install.sh` で同期 |
| チームメンバーと共有不可 | `git clone` + `./install.sh` |
| 他のAI CLI（Codex等）と設定が競合 | プロジェクト単位でインストールし分離可能 |

## リポジトリ構成

```
claude-dev-agents/
├── agents/           # エージェント定義 30個 (.md)
│   ├── conductor.md          # Lead — プランニング、タスク分解
│   ├── dev-lead.md           # Lead — 開発計画/レビュー
│   ├── quality-lead.md       # Lead — 品質ゲート
│   ├── frontend-dev.md       # Worker — React/CSS
│   ├── backend-dev.md        # Worker — API/サーバー
│   ├── code-reviewer.md      # Reviewer — コードレビュー
│   ├── security-auditor.md   # Reviewer — セキュリティ監査
│   ├── tenth-man.md          # Reviewer — 反対意見
│   └── ...                   # 残り22個
├── rules/            # ガバナンスルール 6個 (.md)
│   ├── harness-system.md     # Lead/Worker/Reviewer 役割境界 (alwaysApply)
│   ├── team-lead.md          # Agent Teams オーケストレーション (alwaysApply)
│   ├── spec-guard.md         # スペック整合性チェック (alwaysApply)
│   ├── skill-dispatch.md     # コンテキスト別スキル/エージェントルーティング (alwaysApply)
│   ├── tool-priority.md      # 重複ツール優先順位 (alwaysApply)
│   └── code-review.md        # PRレビューチェックリスト (オンデマンド)
├── install.sh        # コピーベースのインストールスクリプト
└── README.md
```

## セットアップ

### プロジェクトにインストール（デフォルト）

```bash
cd ~/dev/my-app
~/dev/personal/claude-dev-agents/install.sh
```

`agents/` と `rules/` を `~/dev/my-app/.claude/` にコピーします。
プロジェクトごとに独立コピー — Codex等の他のAI CLIとの干渉なし。

### グローバルインストール

```bash
./install.sh --global
```

`~/.claude/` にコピーします（全プロジェクトに適用）。

### 既存シンボリックリンクの削除

以前のシンボリックリンク方式でインストールした場合：

```bash
./install.sh --unlink
```

### 更新の反映

```bash
cd ~/dev/personal/claude-dev-agents && git pull

cd ~/dev/my-app && ~/dev/personal/claude-dev-agents/install.sh  # プロジェクトに再インストール
```

## エージェントシステムアーキテクチャ

```
ハーネス構造 (harness-system.md)：
  Lead (read-only、調整)     → conductor, dev-lead, quality-lead, ops-lead, research-lead
  Worker (full tools、実装)  → frontend-dev, backend-dev, fullstack-dev, database-eng, ...
  Reviewer (read-only、監査) → code-reviewer, security-auditor, tenth-man, arch-advisor, ...

オーケストレーション (team-lead.md)：
  Plan → Contract → Wave → Gate → Review
  各 wave 間に Execution Gate（ビルド/テスト）+ Spec Check

モデルティアリング：
  opus   — リーダー/判断 (conductor, dev-lead, quality-lead, debugger, arch-advisor, tenth-man)
  sonnet — 実行/分析（大部分のワーカー、レビュアー）
  haiku  — 軽量タスク (dep-updater, doc-researcher, type-checker)
```

## 注意事項

- **settings.json は含まれません** — 個人の権限やプラグインリスト（ユーザーごとに異なる）
- **CLAUDE.md は含まれません** — 個人のワークフロー設定
- `agents/` と `rules/` のみを共有する設計です
