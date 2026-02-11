---
name: teardown-worktree
description: 現在のworktreeを削除し、元のリポジトリに作業ディレクトリを戻します。worktreeでの作業が完了した際に使用してください。
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/teardown-worktree.sh *) Bash(cd *) Bash(pwd *) Bash(git worktree *)
---

## 手順

1. **事前チェック**: teardownスクリプトを実行して、worktree情報を取得する。
    - コマンド: `${CLAUDE_PLUGIN_ROOT}/scripts/teardown-worktree.sh`
    - 成功時: 1行目にメインリポジトリのパス、2行目にworktreeのパスが出力される。
    - 終了コード1: メインリポジトリにいる等のエラー。stderrの内容をユーザーに報告し、作業を中断する。
    - 終了コード2: 未コミット変更がある。stderrの変更内容をユーザーに提示し、判断を仰ぐ（破棄 / コミット / 中断）。
      - 破棄を選択した場合: `${CLAUDE_PLUGIN_ROOT}/scripts/teardown-worktree.sh --force` を再実行する。

2. **メインリポジトリへ移動**: 削除前にメインリポジトリへ移動する。
    - コマンド: `cd {メインリポジトリのパス}`
    - カレントディレクトリが削除対象の worktree 内にあると削除に失敗するため、必ず先に移動する。

3. **worktree削除**: worktree を削除する。
    - コマンド: `git worktree remove {worktreeのパス}`
    - ステップ1で変更の破棄を選択した場合は `--force` オプションを付与する。

4. **削除確認**: 削除結果を確認・報告する。
    - コマンド: `git worktree list` と `pwd` で確認する。

## 完了条件

以下の全てを満たすこと：
- [ ] worktree が `git worktree list` に表示されていない
- [ ] 作業ディレクトリが元のリポジトリに戻っている

## 注意点
- ブランチの削除は行わない（PR マージ後に GitHub が自動削除する場合がある）
- カレントディレクトリを削除しないよう、必ず先にメインリポジトリへ `cd` する
