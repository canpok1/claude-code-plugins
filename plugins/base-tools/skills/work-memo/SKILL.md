---
name: work-memo
description: 作業メモファイルの記録・参照・移動を行う時に使うスキル。作業の節目でメモを残したり、過去のメモを参照したり、メモを別ディレクトリへアーカイブ移動する場合に使用する。
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
出力パスの親ディレクトリがメモディレクトリであり、その配下にサブディレクトリ（`done/`, `analyzed/` 等）が存在する。

## メモファイルの移動

メモを指定のサブディレクトリへ移動する:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh <src-abs-path> <dest-subdir>
```

- `<src-abs-path>`: 移動元のメモファイル絶対パス
- `<dest-subdir>`: 移動先のサブディレクトリ名
- 同名ファイルが既に存在する場合はタイムスタンプ付き（`<basename>.YYYYMMDDHHMMSS.md`）に自動リネームされる
- 標準出力に移動先の絶対パスが1行出力される

### ディレクトリの用途

| サブディレクトリ | 用途 |
|---|---|
| `done/` | 作業完了・振り返り済みのメモ（アーカイブ済み） |
| `analyzed/` | 分析済みのメモ（改善Issue登録済み） |

### 用途別の使用例

アーカイブ移動（作業完了時）:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh <src-abs-path> done
```

分析済みディレクトリへの移動:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh <src-abs-path> analyzed
```

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
- 使用スキル: {スキル名1}, {スキル名2}(xN)
```

## 書き込みルール

- 既存ファイルがある場合は Read で読み取ってから Write で追記する（上書き禁止）
- 最初に書き込む時は目的・作業内容チェックリストを設定する
- 各ステップ完了時に作業ログセクションへ追記する
- 作業ログへステップを追記する前に、ファイル末尾を Read で確認し、直前のステップ番号に続く連番で追記する
- 途中に挿入するのではなく、必ずファイル末尾に追加する（順序逆転を防ぐため）
- 作業内容チェックリストは完了時にチェックを付ける
- 各ステップのログには「使用スキル」行を必ず含め、そのステップで呼び出したスキル名を記録する
    - プラグイン名のプレフィックス（`base-tools:` 等）は省略し、スキル名のみ記載する
    - 同一スキルを複数回呼び出した場合は `スキル名(xN)` 形式で回数を付記する（例: `monologue(x3)`）
    - スキルを呼び出していないステップでは `使用スキル: なし` と記載する
