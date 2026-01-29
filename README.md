# Claude Code Plugins Marketplace

Claude Code の機能を拡張するプラグインのマーケットプレイスです。

## 概要

このリポジトリは、Claude Code 向けのプラグインを集約・配布するためのマーケットプレイスです。各プラグインは以下の形式で提供されます:

- **Slash Commands** - カスタムスラッシュコマンド
- **MCP Servers** - Model Context Protocol サーバー
- **Hooks** - イベントフック
- **Composite** - 上記の組み合わせ

## ディレクトリ構成

```
claude-code-plugins/
├── registry/               # プラグインレジストリ
│   └── plugins.json        # 登録済みプラグイン一覧
├── plugins/                # プラグイン本体
│   └── <plugin-name>/      # 各プラグインのディレクトリ
│       ├── manifest.json   # プラグインマニフェスト
│       ├── README.md       # プラグインのドキュメント
│       └── ...             # プラグイン固有のファイル
├── schema/                 # スキーマ定義
│   └── plugin-manifest.schema.json
├── templates/              # プラグインテンプレート
│   └── plugin-template/
├── scripts/                # ユーティリティスクリプト
│   └── install.sh          # インストールスクリプト
└── CONTRIBUTING.md         # コントリビューションガイド
```

## 利用可能なプラグイン

| プラグイン名 | 種別 | 説明 |
|-------------|------|------|
| *近日公開* | - | - |

## インストール

### 個別プラグインのインストール

```bash
# リポジトリをクローン
git clone https://github.com/canpok1/claude-code-plugins.git

# インストールスクリプトを使用
./scripts/install.sh <plugin-name>
```

### 手動インストール

各プラグインの `manifest.json` に記載された設定を、Claude Code の設定ファイルに手動で追加することも可能です。

## プラグインの作成

新しいプラグインを作成するには、`templates/plugin-template/` をコピーして開発を始めてください。

```bash
cp -r templates/plugin-template plugins/my-new-plugin
```

詳細は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## プラグインマニフェスト

各プラグインには `manifest.json` が必要です。スキーマの詳細は [schema/plugin-manifest.schema.json](schema/plugin-manifest.schema.json) を参照してください。

### 基本構造

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "プラグインの説明",
  "author": { "name": "Author Name" },
  "license": "MIT",
  "type": "slash-command",
  "entry": {
    "commands": [],
    "hooks": {},
    "mcpServers": {}
  }
}
```

## ライセンス

MIT License
