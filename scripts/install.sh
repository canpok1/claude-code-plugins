#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY_FILE="$REPO_ROOT/registry/plugins.json"

usage() {
  echo "Usage: $0 <plugin-name>"
  echo ""
  echo "Claude Code プラグインをインストールします。"
  echo ""
  echo "引数:"
  echo "  plugin-name  インストールするプラグインの名前"
  echo ""
  echo "例:"
  echo "  $0 github"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

PLUGIN_NAME="$1"
PLUGIN_DIR="$REPO_ROOT/plugins/$PLUGIN_NAME"
MANIFEST_FILE="$PLUGIN_DIR/manifest.json"

# プラグインディレクトリの確認
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "Error: Plugin '$PLUGIN_NAME' not found in plugins directory."
  echo "Available plugins:"
  ls "$REPO_ROOT/plugins/" 2>/dev/null || echo "  (none)"
  exit 1
fi

# マニフェストの確認
if [ ! -f "$MANIFEST_FILE" ]; then
  echo "Error: manifest.json not found for plugin '$PLUGIN_NAME'."
  exit 1
fi

echo "Installing plugin: $PLUGIN_NAME"
echo "Plugin directory: $PLUGIN_DIR"

# セットアップコマンドの実行
INSTALL_CMD=$(jq -r '.setup.install // empty' "$MANIFEST_FILE" 2>/dev/null)
if [ -n "$INSTALL_CMD" ]; then
  echo "Running install command: $INSTALL_CMD"
  (cd "$PLUGIN_DIR" && eval "$INSTALL_CMD")
fi

# MCP サーバー設定の表示
MCP_SERVERS=$(jq -r '.entry.mcpServers // empty' "$MANIFEST_FILE" 2>/dev/null)
if [ -n "$MCP_SERVERS" ] && [ "$MCP_SERVERS" != "null" ]; then
  echo ""
  echo "This plugin provides MCP servers."
  echo "Add the following to your Claude Code settings (~/.claude/settings.json):"
  echo ""
  echo "$MCP_SERVERS" | jq .
fi

# Hook 設定の表示
HOOKS=$(jq -r '.entry.hooks // empty' "$MANIFEST_FILE" 2>/dev/null)
if [ -n "$HOOKS" ] && [ "$HOOKS" != "null" ]; then
  echo ""
  echo "This plugin provides hooks."
  echo "Add the following to your Claude Code settings (~/.claude/settings.json):"
  echo ""
  echo "$HOOKS" | jq .
fi

# コマンドの表示
COMMANDS=$(jq -r '.entry.commands // empty' "$MANIFEST_FILE" 2>/dev/null)
if [ -n "$COMMANDS" ] && [ "$COMMANDS" != "null" ]; then
  echo ""
  echo "Available commands:"
  echo "$COMMANDS" | jq -r '.[] | "  /\(.name) - \(.description)"'
fi

echo ""
echo "Plugin '$PLUGIN_NAME' installed successfully."
