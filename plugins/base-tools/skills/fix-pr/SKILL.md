---
name: fix-pr
description: 作成済みのプルリクエストに対してCI確認・レビュー対応・マージを行う時に使うスキル。
allowed-tools: Bash(gh pr checks *), Bash(gh pr view *), Bash(gh pr merge *), Bash(gh pr comment *), Bash(gh api *), Bash(git diff *), Bash(git log *), Bash(git status *), Bash(git add *), Bash(git commit *), Bash(git push *), Bash(git ls-remote *), Read, Edit, Grep, Glob
---

## 手順

- [ ] ステップ1：PRのCIステータスを確認する
- [ ] ステップ2：CI失敗があれば原因を特定して修正する
- [ ] ステップ3：レビュー指摘があれば内容を確認して対応する
- [ ] ステップ4：全てのチェックが通ったらマージする

## 注意点

- 全体
    - 節目ごとに作業メモを残すこと。CI結果やレビュー対応の判断理由を記録し、後続の作業で参照できるようにする。
    - PRのIssue紐付けがない場合でもマージを続行してよい。
    - コマンドの実行結果が空・想定外だった場合は、次のアクションへ進む前に状態確認コマンドを挟むこと。
- ステップ1
    - `gh pr checks` でCIの各ジョブのステータスを確認すること。
    - `gh pr view` でPRの現在の状態（タイトル、本文、レビュー状態）を確認すること。出力が空だった場合は `gh pr view --json number,title,body,state,reviews` のように `--json` オプションで再取得すること。
    - 全てのチェックがpassしている場合はステップ2・3をスキップしてステップ4に進むこと。
- ステップ2
    - CI失敗の原因を特定せず盲目的にリトライしないこと。ログを確認し、根本原因を理解した上で修正すること。
    - 修正は論理的にまとまった単位でコミットし、pushすること。
    - 修正後、再度 `gh pr checks` でCIの状態を確認すること。
- ステップ3
    - `gh api` でPRのレビューコメントを取得し、指摘内容を確認すること。
    - レビュー指摘が不明瞭な場合は勝手に解釈せず、`gh pr comment` でコメントして確認すること。
    - 指摘への対応（修正 or 返信）が完了したら、対応内容を作業メモに記録すること。
- ステップ4
    - CIが全てpassし、未対応のレビュー指摘がないことを確認してからマージすること。
    - `gh pr merge` でマージを実行すること。マージ方式はリポジトリのデフォルトに従うこと。
    - `gh pr merge --delete-branch` や `git push origin --delete <branch>` でリモートブランチを削除する場合、実行前に `git ls-remote origin <branch>` でブランチ存在を確認すること。既に削除済みなら削除オプションを付けずマージのみ行う。
