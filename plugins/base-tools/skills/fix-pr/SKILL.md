---
name: fix-pr
description: プルリクエストのCI状態とレビューコメントを確認し、必要な修正と返信を行います。完了条件を満たした場合は自動的にPRをマージします。PR作成後にCI失敗やレビューコメントへの対応が必要な場合や、`/fix-pr` コマンドが実行された場合に使用してください。
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Bash(gh *), Bash(sleep *)
---

## 手順

このチェックリストをコピーし、進行状況の追跡に使用してください：

タスク進捗：
- [ ] ステップ1：プルリクエストの番号を特定する
- [ ] ステップ2：mergeStateStatus を確認し状態に応じて対応する
- [ ] ステップ3：CIの終了を待機する
- [ ] ステップ4：CIの結果を詳細に把握する
- [ ] ステップ5：レビューコメントを把握する
- [ ] ステップ6：レビュワーへのapprove依頼を行う
- [ ] ステップ7：方針に従って対応を行う
- [ ] ステップ8：完了条件を満たしているか確認する
- [ ] ステップ9：Issueとの紐付けを確認する
- [ ] ステップ10：マージ前に mergeStateStatus を再確認する
- [ ] ステップ11：PRのマージを行う

1. プルリクエストの番号を特定する。
    - コマンド: `gh pr view --json number --jq '.number'`
    - PRが存在しない場合はユーザーに報告し、作業を中断する。
2. PRの `mergeStateStatus` を確認し、状態に応じて対応する。
    - コマンド: `gh pr view {PR番号} --json mergeStateStatus --jq '.mergeStateStatus'`
    - 状態別の対応：
        - `BEHIND`: PRブランチへ checkout し、作業ツリーがクリーンであることを確認してからベースブランチをマージする。
            - 事前確認: `gh pr checkout {PR番号}` でPRブランチへ移動し、`git status --porcelain` が空であることを確認する。
            - 作業ツリーが clean でない場合: 未コミットの変更をユーザーに報告し、続行方法の判断を仰ぐ。
            - コマンド: `gh pr view {PR番号} --json baseRefName --jq '.baseRefName'` でベースブランチ名を取得し、`git fetch origin {ベースブランチ} && git merge origin/{ベースブランチ}` でマージする。
        - `DIRTY`: コンフリクトが存在する。PRブランチへ checkout しベースブランチをマージしてコンフリクト解消を試みる。解消が困難な場合はコンフリクト箇所をユーザーに報告し、判断を仰ぐ。
        - `BLOCKED`: 必須チェックまたは必須レビューが未完了。
            - `gh pr view {PR番号} --json reviewDecision --jq '.reviewDecision'` で確認する。
            - `REVIEW_REQUIRED` または `CHANGES_REQUESTED` の場合: GitHub APIのキャッシュにより古い状態が返される可能性があるため、以下のリトライを行う。
                1. 10秒待機してから `reviewDecision` を再取得する。
                2. 再取得しても `REVIEW_REQUIRED` または `CHANGES_REQUESTED` のままの場合、再度10秒待機して再取得する。
                3. リトライは最大3回まで。3回リトライしても状態が変わらない場合、レビュー承認が必要または変更が要求されていることをユーザーに報告し、対応を待つか判断を仰ぐ。
                4. リトライ中に `APPROVED` 等の別の状態に変わった場合は、手順3へ進む。
            - それ以外の場合: 手順3へ進む。
        - `CLEAN`: マージ可能な状態。手順3へ進む。
        - `UNSTABLE`: 必須でないチェックが失敗しているがマージは可能。手順3へ進む。
        - `HAS_HOOKS`: マージフックが設定されている。手順3へ進む。
        - `DRAFT`: ドラフトPRである旨をユーザーに報告し、続行するか判断を仰ぐ。
        - `UNKNOWN` または `null`: 状態が未確定。10秒待機してから再取得する（最大3回まで）。3回取得しても `UNKNOWN`/`null` の場合は手順3へ進む。
3. CIの終了を待機する。
    - コマンド: `gh pr checks {PR番号} --watch`
    - 全チェックが完了するまで待機する。
    - `gh pr checks --watch` が "no checks reported" エラーで失敗した場合：
        - 10秒待機してからリトライする。
        - リトライは最大3回まで。
        - 3回リトライしてもチェックが登録されない場合は、チェック待機をスキップして手順4へ進む（CIが設定されていない、またはトリガー条件に合致しなかったと判断する）。
    - CodeRabbit の rate limit による停止に対応するため、`gh pr checks --watch` は5分のタイムアウト付きで実行する：
        - コマンド: `timeout 300 gh pr checks {PR番号} --watch`
        - 5分以内に全チェックが完了した場合は手順4へ進む。
        - 5分経過してもチェックが完了しない場合（`timeout` によりコマンドが終了した場合）、以下の手順で対応する：
            1. `gh pr checks {PR番号}` で各チェックの状態を確認する。
            2. CodeRabbit のチェックが `pending` の場合、`gh pr comment {PR番号} --body "@coderabbitai review"` でレビューを再起動する。
            3. 10分待機してから `timeout 300 gh pr checks {PR番号} --watch` で再度完了を待機する。
            4. 再度 CodeRabbit が `pending` のままの場合は、手順3-2〜3-3を繰り返す（最大2回まで）。
            5. 2回リトライしても CodeRabbit が完了しない場合は、CodeRabbit の完了を待たずに手順4へ進む。
4. CIの結果を確認する。
    - コマンド: `gh pr checks {PR番号}`
    - 一時的な問題（インフラ障害、flaky test等）の場合は `gh run rerun {run-id}` で再実行し、手順3に戻る。同一ワークフローの再実行は最大2回まで。
    - コード修正が必要な場合は、対応方針を決めて手順7で修正する。
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
    - 取得したスレッドを以下の基準でフィルタリングする：
        - `isResolved` が true → 対応済みのためスキップ
        - `isOutdated` が true かつ未解決 → 最新コードで指摘内容が解消済みか確認し、解消済みならスキップ
        - 上記以外 → 対応が必要
    - スレッド投稿者が bot かどうかを判別する（ログイン名に `[bot]` サフィックスがある、または `github-actions`, `codecov`, `dependabot`, `renovate` 等の既知の bot アカウント）。
    - 対応が必要なスレッドについて方針を決める：
        - 改修提案かつ対応が必要: コード修正と返信
        - 改修提案かつ対応が不要: 理由を添えて返信
6. レビュワーへのapprove依頼を行う。
    - 手順5で取得したレビュースレッドを確認する。
    - レビュースレッドが存在しない場合、または未解決のスレッドが存在する場合はこの手順をスキップし、手順7へ進む。
    - 全スレッドが解決済み（`isResolved: true`）の場合、`reviewDecision` を確認する。
        - コマンド: `gh pr view {PR番号} --json reviewDecision --jq '.reviewDecision'`
        - `CHANGES_REQUESTED` または `REVIEW_REQUIRED` の場合:
            1. PRコメントでレビュワーにapproveを依頼する。
                - コマンド: `gh pr comment {PR番号} --body "全てのレビューコメントに対応しました。このPRをapproveしてください。"`
            2. 60秒待機する。
                - コマンド: `sleep 60`
            3. `reviewDecision` を再確認する。
                - コマンド: `gh pr view {PR番号} --json reviewDecision --jq '.reviewDecision'`
            4. `APPROVED` に変わった場合は手順7へ進む。
            5. まだ `CHANGES_REQUESTED` または `REVIEW_REQUIRED` の場合も手順7へ進む（手順8の完了条件チェックで再評価される）。
        - `APPROVED` またはその他の場合: 手順7へ進む。
7. 手順4と5で決めた方針に従って対応を行う。
    - CI失敗への対応とレビューコメントへのコード修正をまとめて行い、コミット・プッシュする。
    - 各レビューコメントスレッドへ返信を行う。
        - コマンド:
            ```bash
            gh api graphql --input - <<'EOF'
            {
              "query": "mutation($threadId:ID!, $body:String!) { addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) { comment { id body } } }",
              "variables": {
                "threadId": "{スレッドID}",
                "body": "{返信内容}\n\n---\n🤖 Generated with [Claude Code](https://claude.ai/claude-code)"
              }
            }
            EOF
            ```
8. 完了条件を満たしているか確認する。
    - CIが未完了の場合は手順3と同様の方法（リトライ含む）でCIの完了を待機してから手順2に戻る。
    - その他の条件を満たしていない場合は未完了の条件をユーザーに報告し、30秒待機してから手順2に戻る。
    - 手順2からの再実施は最大10回まで。10回を超えた場合は未完了の条件と試行内容をユーザーに報告し、続行するか判断を仰ぐ。
9. Issueとの紐付けを確認する。
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
    - 紐付けの有無に関わらず手順10へ進む。
10. マージ前に `mergeStateStatus` を再確認する。
    - コマンド: `gh pr view {PR番号} --json mergeStateStatus --jq '.mergeStateStatus'`
    - 状態別の対応：
        - `CLEAN`, `UNSTABLE`, `HAS_HOOKS`: マージ可能。手順11へ進む。
        - `BEHIND`: ベースブランチをマージし、手順3に戻る（手順8の回数制限の対象）。
        - `DIRTY`: コンフリクト解消を試みる。解消できた場合はコミット・プッシュして手順3に戻る（手順8の回数制限の対象）。解消が困難な場合はユーザーに報告し、判断を仰ぐ。
        - `BLOCKED`: 必須チェックまたは必須レビューが未完了。
            - `gh pr view {PR番号} --json reviewDecision --jq '.reviewDecision'` で確認する。
            - `REVIEW_REQUIRED` または `CHANGES_REQUESTED` の場合: GitHub APIのキャッシュにより古い状態が返される可能性があるため、以下のリトライを行う。
                1. 10秒待機してから `reviewDecision` を再取得する。
                2. 再取得しても `REVIEW_REQUIRED` または `CHANGES_REQUESTED` のままの場合、再度10秒待機して再取得する。
                3. リトライは最大3回まで。3回リトライしても状態が変わらない場合、レビュー承認が必要または変更が要求されていることをユーザーに報告し、対応を待つか判断を仰ぐ。
                4. リトライ中に `APPROVED` 等の別の状態に変わった場合は、手順3に戻りCIの完了を待機する（手順8の回数制限の対象）。
            - それ以外の場合: 手順3に戻りCIの完了を待機する（手順8の回数制限の対象）。
        - `DRAFT`: ドラフトPRである旨をユーザーに報告し、続行するか判断を仰ぐ。
        - `UNKNOWN` または `null`: 10秒待機してから再取得する（最大3回まで）。3回取得しても確定しない場合はユーザーに報告し、判断を仰ぐ。
11. PRのマージを行う。
    - リポジトリで許可されているマージ方式を確認する。
        - コマンド: `gh api repos/{OWNER}/{REPO} --jq '{squash: .allow_squash_merge, merge: .allow_merge_commit, rebase: .allow_rebase_merge}'`
        - API呼び出しに失敗した場合（権限不足、ネットワークエラー等）: エラー内容をユーザーに報告し、作業を中断する。
    - 以下の優先順位でマージ方式を選択し、対応するフラグを使用する：
        1. squash merge が許可されている場合: `--squash`
        2. merge commit が許可されている場合: `--merge`
        3. rebase merge が許可されている場合: `--rebase`
    - 全てのマージ方式が無効の場合: 利用可能なマージ方式がない旨をユーザーに報告し、リポジトリ設定の確認を促して作業を中断する。
    - コマンド: `gh pr merge {PR番号} {選択したマージ方式フラグ}`
    - マージに成功した場合は完了をユーザーに報告する。
    - マージに失敗した場合、失敗理由を確認し以下の対応を行う：
        - behind状態: ベースブランチをマージし、手順3に戻る（手順8の回数制限の対象）。
        - マージコンフリクト: コンフリクトの解消を試み、解消できた場合はコミット・プッシュして手順3に戻る（手順8の回数制限の対象）。解消が困難な場合はコンフリクト箇所をユーザーに報告し、判断を仰ぐ。
        - 必須チェック未通過: 手順3に戻りCIの完了を待機する（手順8の回数制限の対象）。
        - 必須レビュー未承認: 未承認であることをユーザーに報告し、承認を待つか判断を仰ぐ。
        - 上記いずれにも該当しない場合: 失敗理由の詳細をユーザーに報告し、対処方法の判断を仰ぐ。

## 完了条件

以下の全てを満たすこと：
- [ ] mergeStateStatus が `CLEAN`, `UNSTABLE`, `HAS_HOOKS` のいずれかである
- [ ] 未解決のレビュースレッドへの対応が完了している（返信済み）
- [ ] CI が全て成功している

## 注意点
- 返信時はスレッドの投稿者全員に対してメンションすること
- マージ後にブランチの自動削除は行わない
- レビュースレッドの resolve は行わない。resolve はレビュアー自身の判断に委ねる
