#!/bin/bash

set -euo pipefail

# teardown-worktree.sh
# 現在のworktreeの情報を取得し、削除の準備を行う
# 引数: なし（カレントディレクトリから判定）、--force で未コミット変更があっても続行
# 出力: 1行目=メインリポジトリのパス、2行目=worktreeのパス を標準出力に出力
# 終了コード: 0=成功、1=エラー、2=未コミット変更あり

FORCE=false
for arg in "$@"; do
  case "${arg}" in
    --force)
      FORCE=true
      ;;
    *)
      echo "Error: 不明な引数: ${arg}" >&2
      echo "Usage: $0 [--force]" >&2
      exit 1
      ;;
  esac
done

# メインリポジトリの判定
CURRENT_TOPLEVEL=$(git rev-parse --show-toplevel)
MAIN_REPO=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')

if [[ "${CURRENT_TOPLEVEL}" == "${MAIN_REPO}" ]]; then
  echo "Error: 現在メインリポジトリにいます。worktreeから実行してください。" >&2
  exit 1
fi

WORKTREE_PATH="${CURRENT_TOPLEVEL}"

# 未コミット変更チェック
UNCOMMITTED=$(git status --porcelain)
if [[ -n "${UNCOMMITTED}" ]] && [[ "${FORCE}" == "false" ]]; then
  echo "Error: 未コミットの変更があります:" >&2
  echo "${UNCOMMITTED}" >&2
  exit 2
fi

# メインリポジトリのパスとworktreeのパスを出力
echo "${MAIN_REPO}"
echo "${WORKTREE_PATH}"
