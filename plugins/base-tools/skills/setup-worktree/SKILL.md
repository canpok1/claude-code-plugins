---
name: setup-worktree
description: 指定されたブランチ名でgit worktreeを作成し、作業ディレクトリを切り替えます。`/setup-worktree {ブランチ名}` で使用してください。
argument-hint: "[branch-name]"
allowed-tools: Bash(git *), Bash(mkdir *), Bash(cd *), Bash(pwd *), Bash(test *)
---

## 手順

1. **引数確認**: `$ARGUMENTS` からブランチ名を取得する。未指定の場合はユーザーに報告し、作業を中断する。

2. **リポジトリ情報取得**: プロジェクトルートを取得する。
    - コマンド: `git rev-parse --show-toplevel`

3. **パス決定**: worktree パスを算出する。
    - プロジェクト名を `basename` で取得する。
    - ブランチ名のスラッシュをハイフンに変換する（`tr '/' '-'`）。
    - worktree パス: `{プロジェクトルート}/../{プロジェクト名}.worktrees/{変換後ブランチ名}`
    - 例: プロジェクトルートが `/workspaces/claude-code-plugins`、ブランチ名が `feature/issue-42` の場合
      - worktree パス: `/workspaces/claude-code-plugins.worktrees/feature-issue-42`

4. **事前チェック**:
    - worktree パスが既に存在するか確認する（`test -d`）。
    - 既存の有効な worktree の場合（`git worktree list` に含まれる場合）: そのままステップ8へ進む（ユーザー確認不要）。
    - ディレクトリは存在するが worktree でない場合: ユーザーに報告し、作業を中断する。
    - ブランチがリモートに存在するか確認する（`git branch -r --list "origin/{ブランチ名}"`）。

5. **worktreeベースディレクトリ作成**:
    ```bash
    PROJECT_ROOT=$(git rev-parse --show-toplevel)
    PROJECT_NAME=$(basename "${PROJECT_ROOT}")
    WORKTREE_BASE="${PROJECT_ROOT}/../${PROJECT_NAME}.worktrees"
    mkdir -p "${WORKTREE_BASE}"
    ```
    - `mkdir -p` が失敗した場合は理由を問わず**作業を中止**する。エラー内容をユーザーに報告する。特に権限エラー（`Permission denied`）の場合は、以下のメッセージも併せて報告する：
      > devcontainer環境の場合は `.devcontainer/Dockerfile` で `/workspaces` ディレクトリのオーナーを変更してください。
    - `sudo` による回避は行わない。

6. **新規ブランチでworktree作成**（ブランチがリモートに存在しない場合）:
    ```bash
    git fetch origin main
    git worktree add -b "{ブランチ名}" "${WORKTREE_PATH}" origin/main
    ```

7. **既存ブランチでworktree作成**（ブランチがリモートに存在する場合）:
    ```bash
    git fetch origin "{ブランチ名}"
    git worktree add "${WORKTREE_PATH}" "{ブランチ名}"
    ```

8. **作業ディレクトリ切替**: worktree に移動し、状態を確認・報告する。
    - コマンド: `cd "${WORKTREE_PATH}"` → `pwd` と `git branch --show-current` で確認する。

## 完了条件

以下の全てを満たすこと：
- [ ] worktree が作成されている（または既存 worktree に移動している）
- [ ] 作業ディレクトリが worktree に切り替わっている
- [ ] `git branch --show-current` が指定ブランチを示している
