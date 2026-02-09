#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
WORKSPACE_DIR=$(realpath "$SCRIPT_DIR/..")
PLUGINS_DIR="$WORKSPACE_DIR/plugins"

# setup claude plugin
echo "alias claude='claude --plugin-dir ${PLUGINS_DIR}/my-workflow'" >> ~/.bashrc
echo "alias claude='claude --plugin-dir ${PLUGINS_DIR}/my-workflow'" >> ~/.zshrc

# setup tmux
ln -sf "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
