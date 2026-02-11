# Claude Code 開発ガイドライン

このドキュメントは、Claude Code がこのプロジェクトで作業する際に従うべきガイドラインを定義します。

## コミットメッセージルール

### デフォルトフォーマット: Conventional Commits

このプロジェクトでは、コミットメッセージのデフォルトフォーマットとして [Conventional Commits](https://www.conventionalcommits.org/) を採用しています。

**注意**: プロジェクト固有のルール（commitlint設定、プロジェクト内のCLAUDE.md指定等）がある場合は、そちらのルールを優先してください。

### フォーマット

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### type の種類

- **feat**: 新機能の追加
- **fix**: バグ修正
- **docs**: ドキュメントのみの変更
- **style**: コードの動作に影響しない変更（空白、フォーマット、セミコロンの欠落など）
- **refactor**: バグ修正や機能追加ではないコードの変更
- **test**: テストの追加や既存テストの修正
- **chore**: ビルドプロセスやドキュメント生成などの補助ツールやライブラリの変更
- **ci**: CI/CD設定ファイルやスクリプトの変更

### scope（オプション）

変更の範囲を示します。例:
- `plugin`: プラグイン関連
- `skill`: スキル関連
- `config`: 設定ファイル関連
- `workflow`: ワークフロー関連

### description

- **日本語で記述**してください（このプロジェクトの慣習に従います）
- 変更内容を簡潔に説明します
- 現在形で記述します（例: "追加する"ではなく"追加"）
- 最初の文字は小文字で始めます
- 文末にピリオドを付けません

### 例

```
feat(skill): solve-issueスキルを追加

GitHub Issueの内容を把握し、実装からPR作成までを
一貫して行うスキルを追加しました。

Closes #19
```

```
fix(workflow): setup-worktreeの権限エラーを修正

worktreeベースディレクトリの権限エラーに対応しました。
```

```
docs: READMEにプラグイン一覧を追加
```

```
chore(config): settings.jsonに権限設定を追加
```

### Breaking Changes

破壊的変更がある場合は、footerに `BREAKING CHANGE:` を記載するか、typeの後に `!` を付けます:

```
feat(api)!: ユーザー認証APIを刷新

BREAKING CHANGE: 旧APIエンドポイントは廃止されました。
新しいエンドポイントに移行してください。
```

### Issue参照

関連するIssueがある場合は、footerでIssue番号を参照してください:

```
feat(plugin): GitHub連携プラグインを追加

Closes #10
Related to #8, #9
```

## コミット時の注意事項

- 論理的に独立した変更は別々のコミットに分けてください
- コミットメッセージは変更の「何を」だけでなく「なぜ」を説明してください
- 大きな変更の場合は、bodyセクションを使って詳細を記載してください
