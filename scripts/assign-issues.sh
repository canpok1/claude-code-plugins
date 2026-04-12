#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PRINT_MODE=false
ASSIGN_COUNT=2

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p) PRINT_MODE=true; shift ;;
    -c) ASSIGN_COUNT="$2"; shift 2 ;;
    *) echo "Usage: $0 [-p] [-c count]" >&2; exit 1 ;;
  esac
done

if ! [[ "$ASSIGN_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Error: count must be a number" >&2
  exit 1
fi

REPO="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"

# readyラベル付き + assign-to-claude/in-progress-by-claude 未付与のIssueをカウント
ISSUE_COUNT=$(gh issue list \
  --repo "$REPO" \
  --state open \
  --label "ready" \
  --json labels,number \
  --jq '[.[] | select(
    (.labels | map(.name) | index("assign-to-claude") | not) and
    (.labels | map(.name) | index("in-progress-by-claude") | not)
  )] | length')

if [[ "$ISSUE_COUNT" -eq 0 ]]; then
  echo "No issues to assign"
  exit 0
fi

echo "Found ${ISSUE_COUNT} issue(s) ready for assignment"

cd "$WORKSPACE_DIR"

if [[ "$PRINT_MODE" == "true" ]]; then
  "${SCRIPT_DIR}/claude-stream.sh" -p "/assign-issues --count ${ASSIGN_COUNT}"
else
  claude -p "/assign-issues --count ${ASSIGN_COUNT}"
fi
