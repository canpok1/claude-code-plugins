#!/usr/bin/env bash
set -euo pipefail

REPO="canpok1/claude-code-plugins"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCH}"
DIR="workflow-scripts"
FILES=(
  "auto-solve.sh"
  "auto-assign.sh"
  "solve-issue.sh"
  "claude-stream.sh"
)

FORCE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f) FORCE=true; shift ;;
    *) echo "Usage: $0 [-f]" >&2; exit 1 ;;
  esac
done

mkdir -p "$DIR"

for file in "${FILES[@]}"; do
  dest="${DIR}/${file}"
  if [[ -f "$dest" ]] && [[ "$FORCE" != "true" ]]; then
    echo "[SKIP] ${dest} already exists (use -f to overwrite)"
    continue
  fi

  url="${BASE_URL}/${DIR}/${file}"
  if curl -sfL -o "$dest" "$url"; then
    chmod +x "$dest"
    echo "[OK]   ${dest}"
  else
    echo "[FAIL] ${dest} (download failed)"
  fi
done
