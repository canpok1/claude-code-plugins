---
name: create-pr
description: プルリクエストを作成する時に使うスキル。ブランチのpush、差分確認、PRタイトル・本文の作成、gh pr createによるPR作成までを行う。
allowed-tools: Bash(gh pr create *), Bash(gh pr view *), Bash(git push *), Bash(git diff *), Bash(git log *), Bash(git status *), Bash(git branch *)
---

## 手順

- [ ] ステップ1：ブランチの状態を確認する
- [ ] ステップ2：ベースブランチとの差分を確認する
- [ ] ステップ3：PRタイトル・本文を作成し、PRを作成する
- [ ] ステップ4：作成されたPRの内容を確認する

## 注意点

- 全体
    - 節目ごとに作業メモを残すこと。PR作成の判断やタイトル・本文の決定理由を記録し、後続の作業で参照できるようにする。
    - コマンドの実行結果が空・想定外だった場合は、次のアクションへ進む前に状態確認コマンドを挟むこと。
- ステップ1
    - `git status` で未コミットの変更がないか確認すること。
    - `git branch` で現在のブランチ名を確認すること。
    - リモートブランチの追跡状態を確認し、未pushの場合は `git push -u origin {branch}` でpushすること。push後は `git status` で `Your branch is up to date with 'origin/{branch}'` を確認し、追跡状態が期待通りになっているか確かめること。
- ステップ2
    - `git log` でベースブランチから分岐後のコミット履歴を確認すること。
    - `git diff {base-branch}...HEAD` でベースブランチとの差分を確認すること。
    - コミットが1つもない場合はPR作成を中止し、ユーザーに報告すること。
- ステップ3
    - PRタイトルはプロジェクトのコミットメッセージ規約（Conventional Commits）に沿った形式にすること。
    - PR本文にはSummary（変更概要）を含めること。
    - PR本文の末尾に以下のフッターを付与すること:
      ```
      🤖 Generated with [Claude Code](https://claude.ai/code)
      ```
    - 関連するIssueがある場合は `Closes #XX` をPR本文に含めること。
    - `gh pr create` でPRを作成すること。
- ステップ4
    - `gh pr view` で作成されたPRの内容（タイトル、本文、ベースブランチ、差分）を確認すること。出力が空だった場合は `gh pr view --json number,title,body,baseRefName` のように `--json` オプションで再取得すること。
    - 想定通りに作成できたか確認し、問題があればユーザーに報告すること。
