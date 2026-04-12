#!/bin/bash
# 作業メモファイルをアーカイブ先サブディレクトリへ移動するスクリプト
#
# 同名ファイルが既に存在する場合はタイムスタンプ付き（<basename>.YYYYMMDDHHMMSS.md）で
# リネームして衝突を回避する。
#
# メモ保存先:
#   通常のリポジトリ: {repo}/.tmp/memo/<dest-subdir>/
#   worktree の場合: {main-repo}/.tmp/memo/<dest-subdir>/
#
# 使用方法:
#   ${CLAUDE_PLUGIN_ROOT}/skills/work-memo/scripts/move-memo.sh <src-abs-path> <dest-subdir>
#
# 引数:
#   <src-abs-path>   移動元のメモファイル絶対パス
#   <dest-subdir>    メモディレクトリ配下のサブディレクトリ名（例: done, issued）
#
# 出力:
#   移動先の絶対パスを標準出力に1行出力する
#
# 終了コード:
#   0: 正常完了
#   1: エラー（引数不足、移動元不在など）

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <src-abs-path> <dest-subdir>" >&2
    exit 1
fi

SRC=$1
DEST_SUBDIR=$2

if [[ ! -f "$SRC" ]]; then
    echo "Error: source file does not exist: $SRC" >&2
    exit 1
fi

BASE_DIR=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)") || {
    echo "Error: failed to resolve base directory (not a git repository?)" >&2
    exit 1
}

DEST_DIR="${BASE_DIR}/.tmp/memo/${DEST_SUBDIR}"
mkdir -p "$DEST_DIR"

BASE=$(basename "$SRC" .md)
TARGET="${DEST_DIR}/${BASE}.md"

if [[ -e "$TARGET" ]]; then
    TS=$(date +%Y%m%d%H%M%S)
    TARGET="${DEST_DIR}/${BASE}.${TS}.md"
fi

mv "$SRC" "$TARGET"
echo "$TARGET"
