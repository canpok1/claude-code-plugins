#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
WORKSPACE_DIR=$(realpath "$SCRIPT_DIR/..")

echo "alias claude='claude --plugin-dir $WORKSPACE_DIR'" >> ~/.bashrc
echo "alias claude='claude --plugin-dir $WORKSPACE_DIR'" >> ~/.zshrc
