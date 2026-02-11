#!/bin/bash

set -euo pipefail

# リモート環境以外では何もしない
if [[ -z "${CLAUDE_CODE_REMOTE:-}" ]]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SOURCE="${PROJECT_ROOT}/plugins/base-tools/skills"
SKILLS_TARGET="${HOME}/.claude/skills"

# スキルディレクトリへのシンボリックリンクを作成
if [[ -d "${SKILLS_SOURCE}" ]]; then
  mkdir -p "${SKILLS_TARGET}"
  for skill_dir in "${SKILLS_SOURCE}"/*/; do
    skill_name=$(basename "${skill_dir}")
    link_path="${SKILLS_TARGET}/${skill_name}"
    if [[ ! -e "${link_path}" ]]; then
      ln -s "${skill_dir%/}" "${link_path}"
      echo "Created symlink: ${link_path} -> ${skill_dir%/}"
    fi
  done
fi

# GitHub CLIをインストール
"${PROJECT_ROOT}/plugins/base-tools/scripts/install-gh.sh"
