#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PRINT_MODE_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p) PRINT_MODE_FLAG="-p"; shift ;;
    *) echo "Usage: $0 [-p]" >&2; exit 1 ;;
  esac
done

REPO="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"

RUNNING=true
trap 'RUNNING=false; echo ""; echo "Shutting down..."; exit 0' SIGINT SIGTERM

echo "Watching queued issues in ${REPO}..."

while $RUNNING; do
  # assign-to-claudeラベル付き + in-progress-by-claude未付与のIssueを検索
  ISSUE=$(gh issue list \
    --repo "$REPO" \
    --state open \
    --label "assign-to-claude" \
    --json number,title,labels \
    --jq '[.[] | select(.labels | map(.name) | index("in-progress-by-claude") | not)] | sort_by(.number) | first // empty')

  if [[ -n "$ISSUE" ]]; then
    ISSUE_NUMBER=$(echo "$ISSUE" | jq -r '.number')
    ISSUE_TITLE=$(echo "$ISSUE" | jq -r '.title')
    echo ""
    echo "#${ISSUE_NUMBER} ${ISSUE_TITLE}"
    "${SCRIPT_DIR}/solve-issue.sh" $PRINT_MODE_FLAG "$ISSUE_NUMBER" || true
  else
    printf "."
  fi

  sleep 60
done
