---
name: setup-worktree
description: 指定されたブランチ名でgit worktreeを作成し、作業ディレクトリを切り替えます。`/setup-worktree {ブランチ名}` で使用してください。
argument-hint: "[branch-name]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-worktree.sh *) Bash(cd *) Bash(pwd *) Bash(git branch *)
---

## 手順

1. **引数確認**: `$ARGUMENTS` からブランチ名を取得する。未指定の場合はユーザーに報告し、作業を中断する。

2. **スクリプト実行**: worktree作成スクリプトを実行する。
    - コマンド: `${CLAUDE_PLUGIN_ROOT}/scripts/setup-worktree.sh {ブランチ名}`
    - スクリプトは作成したworktreeのパスを標準出力に出力する。
    - エラーの場合はstderrにメッセージが出力され、終了コード1で終了する。エラー内容をユーザーに報告し、作業を中断する。

3. **作業ディレクトリ切替と許可設定**: スクリプトが出力したパスに移動し、編集許可を設定して状態を確認・報告する。
    - `cd {出力されたパス}` で移動する。
    - `/add-dir` コマンドで作業ディレクトリを編集許可リストに追加する。
    - `pwd` と `git branch --show-current` で確認する。

## 完了条件

以下の全てを満たすこと：
- [ ] worktree が作成されている（または既存 worktree に移動している）
- [ ] 作業ディレクトリが worktree に切り替わっている
- [ ] `/add-dir` で作業ディレクトリが編集許可リストに追加されている
- [ ] `git branch --show-current` が指定ブランチを示している
