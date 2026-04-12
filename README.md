# Claude Code Plugins Marketplace

Claude Code の機能を拡張するプラグインのマーケットプレイスです。GitHub Issue の対応からコードレビュー、PR作成までを自動化するスキルセットを提供します。

## 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストールされていること
- Git が利用可能であること
- （推奨）[GitHub CLI (`gh`)](https://cli.github.com/) — `base-tools` プラグインの `SessionStart` フックにより自動インストールされます

## インストール

Claude Code 内で以下のスラッシュコマンドを実行してください。

マーケットプレイスの追加:

```
/plugin marketplace add canpok1/claude-code-plugins
```

プラグインのインストール:

```
/plugin install github@canpok1-plugins
```

> **Note**: 上記はターミナルのシェルコマンドではなく、Claude Code 内で実行するスラッシュコマンドです。

## プラグイン一覧

### base-tools

GitHub Issue の対応を一貫して自動化する基本ツールプラグインです。

#### スキル

**Workflow スキル**（手順の目的を記述し、LLM が適切な Atomic スキルを自動選択して実行します）:

| スキル名 | 説明 | 実行例 |
|----------|------|--------|
| `solve-issue` | GitHub Issue の対応を一貫して行う（要件把握〜実装〜PR作成〜マージ） | `/base-tools:solve-issue 42` |

**Atomic スキル**（各ステップの単一責務を担います）:

| スキル名 | 説明 | 実行例 |
|----------|------|--------|
| `read-issue` | GitHub Issue の内容を確認し、実装要件を整理する | `/base-tools:read-issue 42` |
| `tdd` | テスト駆動開発（TDD）で Red→Green→Refactor のサイクルを回す | `/base-tools:tdd ログイン機能の実装` |
| `self-review` | 自分が書いたコードの変更内容をレビューし、指摘点を洗い出す | `/base-tools:self-review` |
| `create-pr` | プルリクエストを作成する | `/base-tools:create-pr` |
| `fix-pr` | 作成済み PR の CI 確認・レビュー対応・マージを行う | `/base-tools:fix-pr` |
| `work-memo` | 作業メモの記録・参照を行う | `/base-tools:work-memo` |
| `retro` | 作業の振り返りを行う | `/base-tools:retro` |

#### フック

| イベント | 動作 |
|----------|------|
| `SessionStart` | GitHub CLI (`gh`) がインストールされていない場合、自動でインストールします |

## 設計思想

### 2層構造（Workflow / Atomic）

このプラグインは **Workflow** 層と **Atomic** 層の2層構造で設計されています。

- **Workflow 層**: 手順の「目的」のみを記述します。各ステップで何を達成すべきかを定義し、具体的な実行は LLM が目的に合致する Atomic スキルを自動選択して行います。
- **Atomic 層**: 各ステップの単一責務を担います。Issue の読み取り、TDD による実装、セルフレビューなど、それぞれが独立した機能を提供します。

### スキルの上書き

利用者はプロジェクト側で同じ目的のスキルを定義することで、Atomic スキルを上書きできます。例えば、プロジェクト固有のテスト手法がある場合、プロジェクトの `.claude/skills/` に独自の `tdd` スキルを配置すれば、`solve-issue` ワークフロー内で自動的にそちらが使用されます。

## アップデート・アンインストール

プラグインのアップデート:

```
/plugin update
```

プラグインのアンインストール:

```
/plugin uninstall github@canpok1-plugins
```

マーケットプレイスの削除:

```
/plugin marketplace remove canpok1/claude-code-plugins
```

## コントリビュート

Issue や Pull Request は [GitHub リポジトリ](https://github.com/canpok1/claude-code-plugins) で受け付けています。

## ライセンス

MIT License
