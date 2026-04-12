#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PRINT_MODE_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p) PRINT_MODE_FLAG="-p"; shift ;;
    *)
      if [[ -z "${MIN_QUEUE:-}" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
        MIN_QUEUE="$1"; shift
      else
        echo "Usage: $0 [-p] <min-queue>" >&2; exit 1
      fi
      ;;
  esac
done

if [[ -z "${MIN_QUEUE:-}" ]]; then
  echo "Error: min-queue is required" >&2
  echo "Usage: $0 [-p] <min-queue>" >&2
  exit 1
fi

REPO="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"

# 多重起動防止
LOCK_DIR="${WORKSPACE_DIR}/.tmp/locks"
mkdir -p "$LOCK_DIR"
lock_file="${LOCK_DIR}/auto-assign"

exec 9>"$lock_file"
if ! flock -n 9; then
  echo "auto-assign is already running"
  exit 1
fi

RUNNING=true
trap 'RUNNING=false; echo ""; echo "Shutting down..."; exit 0' SIGINT SIGTERM

echo "Watching queue in ${REPO} (min-queue: ${MIN_QUEUE})..."

while $RUNNING; do
  # assign-to-claudeラベル付きのopen Issue数をカウント
  QUEUE_COUNT=$(gh issue list \
    --repo "$REPO" \
    --state open \
    --label "assign-to-claude" \
    --json number \
    --jq 'length')

  if [[ "$QUEUE_COUNT" -lt "$MIN_QUEUE" ]]; then
    echo ""
    echo "Queue: ${QUEUE_COUNT} (< ${MIN_QUEUE}), assigning new issues..."
    "${SCRIPT_DIR}/assign-issues.sh" $PRINT_MODE_FLAG -c 1 || true
  else
    printf "."
  fi

  sleep 60
done
