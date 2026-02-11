---
name: teardown-worktree
description: 現在のworktreeを削除し、元のリポジトリに作業ディレクトリを戻します。worktreeでの作業が完了した際に使用してください。
allowed-tools: Bash(git:*), Bash(cd:*), Bash(pwd:*)
---

## 手順

1. **worktree判定**: 現在メインリポジトリにいるか確認する。
    - `git worktree list` の最初の行（メインリポジトリ）と `git rev-parse --show-toplevel` を比較する。
    - メインリポジトリにいる場合はユーザーに報告し、作業を中断する。

2. **メインリポジトリパス取得**: `git worktree list --porcelain` の最初のエントリからメインリポジトリのパスを取得する。

3. **未コミット変更チェック**: `git status --porcelain` で未コミットの変更がないか確認する。
    - 変更がある場合はユーザーに判断を仰ぐ（破棄 / コミット / 中断）。

4. **worktreeパス記録**: 現在の worktree パスを記録する。
    - コマンド: `WORKTREE_PATH=$(git rev-parse --show-toplevel)`

5. **メインリポジトリへ移動**: 削除前にメインリポジトリへ移動する。
    - コマンド: `cd "${MAIN_REPO_PATH}"`
    - カレントディレクトリが削除対象の worktree 内にあると削除に失敗するため、必ず先に移動する。

6. **worktree削除**: worktree を削除する。
    - コマンド: `git worktree remove "${WORKTREE_PATH}"`
    - ステップ3で変更の破棄を選択した場合は `--force` オプションを付与する。

7. **削除確認**: 削除結果を確認・報告する。
    - コマンド: `git worktree list` と `pwd` で確認する。

## 完了条件

以下の全てを満たすこと：
- [ ] worktree が `git worktree list` に表示されていない
- [ ] 作業ディレクトリが元のリポジトリに戻っている

## 注意点
- ブランチの削除は行わない（PR マージ後に GitHub が自動削除する場合がある）
- カレントディレクトリを削除しないよう、必ず先にメインリポジトリへ `cd` する
