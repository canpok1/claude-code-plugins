#!/bin/bash

set -euo pipefail

# setup-worktree.sh
# 指定されたブランチ名でgit worktreeを作成する
# 引数: ブランチ名
# 出力: 作成したworktreeのパスを標準出力に出力
# 終了コード: 0=成功、1=エラー

BRANCH="${1:-}"

if [[ -z "${BRANCH}" ]]; then
  echo "Error: ブランチ名を指定してください" >&2
  echo "Usage: $0 <branch-name>" >&2
  exit 1
fi

# リポジトリ情報取得
PROJECT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_NAME=$(basename "${PROJECT_ROOT}")
BRANCH_DIR=$(echo "${BRANCH}" | tr '/' '-')
WORKTREE_BASE="${PROJECT_ROOT}/../${PROJECT_NAME}.worktrees"
WORKTREE_PATH="${WORKTREE_BASE}/${BRANCH_DIR}"

# 事前チェック: worktreeパスが既に存在するか
if [[ -d "${WORKTREE_PATH}" ]]; then
  # git worktree listに含まれるか確認
  if git worktree list | grep -q "${WORKTREE_PATH}"; then
    echo "${WORKTREE_PATH}"
    exit 0
  else
    echo "Error: ${WORKTREE_PATH} は既に存在しますが、有効なworktreeではありません" >&2
    exit 1
  fi
fi

# worktreeベースディレクトリ作成
if ! mkdir -p "${WORKTREE_BASE}" 2>/dev/null; then
  echo "Error: ベースディレクトリの作成に失敗しました: ${WORKTREE_BASE}" >&2
  echo "devcontainer環境の場合は .devcontainer/Dockerfile で /workspaces ディレクトリのオーナーを変更してください。" >&2
  exit 1
fi

# リモートブランチの存在確認
REMOTE_BRANCH=$(git branch -r --list "origin/${BRANCH}")

if [[ -n "${REMOTE_BRANCH}" ]]; then
  # 既存ブランチでworktree作成
  git fetch origin "${BRANCH}" >&2
  git worktree add "${WORKTREE_PATH}" "${BRANCH}" >&2
else
  # 新規ブランチでworktree作成
  git fetch origin main >&2
  git worktree add -b "${BRANCH}" "${WORKTREE_PATH}" origin/main >&2
fi

echo "${WORKTREE_PATH}"
