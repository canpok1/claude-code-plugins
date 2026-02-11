#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
WORKSPACE_DIR=$(realpath "$SCRIPT_DIR/..")
PLUGINS_DIR="$WORKSPACE_DIR/plugins"

# setup claude plugin
CLAUDE_COMMAND="claude --plugin-dir ${PLUGINS_DIR}/base-tools"
echo "alias claude='${CLAUDE_COMMAND}'" >> ~/.bashrc
echo "alias claude='${CLAUDE_COMMAND}'" >> ~/.zshrc

# setup tmux
ln -sf "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
