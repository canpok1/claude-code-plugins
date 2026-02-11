---
name: fix-pr
description: プルリクエストのCI状態とレビューコメントを確認し、必要な修正と返信を行います。完了条件を満たした場合は自動的にPRをマージします。PR作成後にCI失敗やレビューコメントへの対応が必要な場合や、`/fix-pr` コマンドが実行された場合に使用してください。
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git:*), Bash(gh:*), Bash(sleep:*)
---

## 手順

このチェックリストをコピーし、進行状況の追跡に使用してください：

タスク進捗：
- [ ] ステップ1：プルリクエストの番号を特定する
- [ ] ステップ2：PRブランチがベースブランチより遅れていないか確認する
- [ ] ステップ3：CIの終了を待機する
- [ ] ステップ4：CIの結果を詳細に把握する
- [ ] ステップ5：レビューコメントを把握する
- [ ] ステップ6：方針に従って対応を行う
- [ ] ステップ7：完了条件を満たしているか確認する
- [ ] ステップ8：Issueとの紐付けを確認する
- [ ] ステップ9：マージ前にbehind状態を再確認する
- [ ] ステップ10：PRのマージを行う

1. プルリクエストの番号を特定する。
    - コマンド: `gh pr view --json number --jq '.number'`
    - PRが存在しない場合はユーザーに報告し、作業を中断する。
2. PRブランチがベースブランチより遅れていないか確認する。
    - コマンド: `gh pr view {PR番号} --json mergeStateStatus --jq '.mergeStateStatus'`
    - `BEHIND` の場合、PRブランチへ checkout し、作業ツリーがクリーンであることを確認してからベースブランチをマージする。
        - 事前確認: `gh pr checkout {PR番号}` でPRブランチへ移動し、`git status --porcelain` が空であることを確認する。
        - コマンド: `gh pr view {PR番号} --json baseRefName --jq '.baseRefName'` でベースブランチ名を取得し、`git fetch origin {ベースブランチ} && git merge origin/{ベースブランチ}` でマージする。
3. CIの終了を待機する。
    - コマンド: `gh pr checks {PR番号} --watch`
    - 全チェックが完了するまで待機する。
4. CIの結果を確認する。
    - コマンド: `gh pr checks {PR番号}`
    - 一時的な問題（インフラ障害、flaky test等）の場合は `gh run rerun {run-id}` で再実行し、手順3に戻る。同一ワークフローの再実行は最大2回まで。
    - コード修正が必要な場合は、対応方針を決めて手順6で修正する。
5. レビューコメントを把握し、対応方針を決める。
    - コマンド:
        ```bash
        gh api graphql --input - <<'EOF'
        {
          "query": "query($owner:String!, $repo:String!, $number:Int!, $after:String) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { reviewThreads(first:100, after:$after) { pageInfo { hasNextPage endCursor } nodes { id isResolved isOutdated comments(first:100) { nodes { author { login } body } } } } } } }",
          "variables": {
            "owner": "{OWNER}",
            "repo": "{REPO}",
            "number": {PR番号}
          }
        }
        EOF
        ```
    - `hasNextPage` が true の間は `variables` に `"after": "{endCursor}"` を追加して繰り返し、全スレッドを取得する。
    - 改修提案かつ対応が必要: コード修正と返信
    - 改修提案かつ対応が不要: 理由を添えて返信
6. 手順4と5で決めた方針に従って対応を行う。
    - CI失敗への対応とレビューコメントへのコード修正をまとめて行い、コミット・プッシュする。
    - 各レビューコメントスレッドへ返信を行う。
        - コマンド:
            ```bash
            gh api graphql --input - <<'EOF'
            {
              "query": "mutation($threadId:ID!, $body:String!) { addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) { comment { id body } } }",
              "variables": {
                "threadId": "{スレッドID}",
                "body": "{返信内容}"
              }
            }
            EOF
            ```
7. 完了条件を満たしているか確認する。
    - CIが未完了の場合は `gh pr checks {PR番号} --watch` を使用してCIの完了を待機してから手順2に戻る。
    - その他の条件を満たしていない場合は未完了の条件をユーザーに報告し、30秒待機してから手順2に戻る。
    - 手順2からの再実施は最大10回まで。10回を超えた場合は未完了の条件と試行内容をユーザーに報告し、続行するか判断を仰ぐ。
8. Issueとの紐付けを確認する。
    - コマンド:
        ```bash
        gh api graphql --input - <<'EOF'
        {
          "query": "query($owner:String!, $repo:String!, $number:Int!) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { closingIssuesReferences(first:10) { nodes { number title } } } } }",
          "variables": {
            "owner": "{OWNER}",
            "repo": "{REPO}",
            "number": {PR番号}
          }
        }
        EOF
        ```
    - 紐付けがある場合は手順9へ進む。
    - 紐付けがない場合（`closingIssuesReferences` が空）、ユーザーに警告し、続行の承認を得る。
    - ユーザーが続行を承認した場合は手順9へ進む。承認しない場合は作業を中断する。
9. マージ前にbehind状態を再確認する。
    - コマンド: `gh pr view {PR番号} --json mergeStateStatus --jq '.mergeStateStatus'`
    - behind状態が `null` の場合は10秒待機してから再取得する（最大3回まで）。
    - behind状態が `BEHIND` の場合はベースブランチをマージし、手順3に戻る（手順7の回数制限の対象）。
    - behind状態が `BEHIND` でない場合は手順10へ進む。
10. PRのマージを行う。
    - コマンド: `gh pr merge {PR番号}`
    - マージ方式はリポジトリのデフォルト設定に従う。
    - マージに成功した場合は完了をユーザーに報告する。
    - マージに失敗した場合、失敗理由を確認し以下の対応を行う：
        - behind状態: ベースブランチをマージし、手順3に戻る（手順7の回数制限の対象）。
        - マージコンフリクト: コンフリクトの解消を試み、解消できた場合はコミット・プッシュして手順3に戻る（手順7の回数制限の対象）。解消が困難な場合はコンフリクト箇所をユーザーに報告し、判断を仰ぐ。
        - 必須チェック未通過: 手順3に戻りCIの完了を待機する（手順7の回数制限の対象）。
        - 必須レビュー未承認: 未承認であることをユーザーに報告し、承認を待つか判断を仰ぐ。
        - 上記いずれにも該当しない場合: 失敗理由の詳細をユーザーに報告し、対処方法の判断を仰ぐ。

## 完了条件

以下の全てを満たすこと：
- [ ] PRブランチがベースブランチに対して遅れていない（behind状態でない）
- [ ] 改修提案への対応が完了し、返信済み
- [ ] 対応不要なコメントへの返信が完了している
- [ ] CI が全て成功している

## 注意点
- 返信時はスレッドの投稿者全員に対してメンションすること
- マージ後にブランチの自動削除は行わない
