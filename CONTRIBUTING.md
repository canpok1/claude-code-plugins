# コントリビューションガイド

Claude Code Plugins Marketplace へのコントリビューションを歓迎します。

## プラグインの追加方法

### 1. テンプレートからプラグインを作成

```bash
cp -r templates/plugin-template plugins/<your-plugin-name>
```

### 2. manifest.json を編集

`manifest.json` を編集し、プラグインの情報を記載します。スキーマは `schema/plugin-manifest.schema.json` に準拠してください。

必須フィールド:

| フィールド | 説明 |
|-----------|------|
| `name` | プラグインの一意な識別子 (kebab-case) |
| `version` | セマンティックバージョン (例: `1.0.0`) |
| `description` | プラグインの短い説明 (200文字以内) |
| `author` | 作者情報 |
| `type` | プラグインの種別 (`slash-command`, `mcp-server`, `hook`, `composite`) |

### 3. プラグインを実装

プラグインの種別に応じて実装します:

#### Slash Command

カスタムのスラッシュコマンドを追加します。`entry.commands` にコマンド定義を記載してください。

#### MCP Server

MCP (Model Context Protocol) サーバーとして動作するプラグインです。`entry.mcpServers` にサーバー設定を記載してください。

#### Hook

Claude Code のイベントに応じて実行されるフックです。`entry.hooks` にフック定義を記載してください。

#### Composite

上記の組み合わせです。複数の entry を定義できます。

### 4. README.md を作成

プラグインの使い方、設定方法、機能を README.md に記載してください。

### 5. レジストリに登録

`registry/plugins.json` の `plugins` 配列にプラグインの情報を追加します:

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "プラグインの説明",
  "type": "slash-command",
  "path": "plugins/your-plugin-name"
}
```

### 6. プルリクエストを作成

変更をブランチにコミットし、プルリクエストを作成してください。

## コーディング規約

- プラグイン名は kebab-case を使用
- バージョンはセマンティックバージョニングに従う
- 各プラグインに README.md を含める
- `manifest.json` はスキーマに準拠すること

## レビュー基準

プルリクエストは以下の基準でレビューされます:

- マニフェストがスキーマに準拠しているか
- ドキュメントが十分か
- セキュリティ上の問題がないか
- 既存のプラグインと名前が衝突しないか
