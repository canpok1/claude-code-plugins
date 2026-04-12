---
name: work-memo
description: 作業メモファイルの記録・参照を行う時に使うスキル。作業の節目でメモを残したり、過去のメモを参照する場合に使用する。
agent: general-purpose
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/get-memo-path.sh), Bash(${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh *), Read, Write, Edit
---

## メモファイルのパスの取得

現在のブランチに対応するメモファイルのパスを取得する:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/get-memo-path.sh
```

標準出力に絶対パスを出力する。メモディレクトリは自動作成される。
ファイルが存在しない場合は、過去のメモがないものとして扱う。

## メモファイルのアーカイブ

作業が完了したメモを `done/` へアーカイブ移動する:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh <src-abs-path> done
```

- `<src-abs-path>`: 移動元のメモファイル絶対パス
- 同名ファイルが既に存在する場合はタイムスタンプ付き（`<basename>.YYYYMMDDHHMMSS.md`）に自動リネームされる
- 標準出力に移動先の絶対パスが1行出力される

## メモファイルのテンプレート

新規作成時は以下のテンプレートに従う。

```markdown
# {作業タイトル}

## 目的

{作業の目的を要約}

## 作業内容

- [ ] {タスク1}
- [ ] {タスク2}

## 作業ログ

### ステップ1: {ステップ名} (YYYY-MM-DD HH:MM)
- {内容}
```

## 書き込みルール

- 既存ファイルがある場合は Read で読み取ってから Write で追記する（上書き禁止）
- 最初に書き込む時は目的・作業内容チェックリストを設定する
- 各ステップ完了時に作業ログセクションへ追記する
- 作業内容チェックリストは完了時にチェックを付ける
