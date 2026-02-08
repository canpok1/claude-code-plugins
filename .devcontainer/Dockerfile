FROM mcr.microsoft.com/devcontainers/base:noble

ENV CLAUDE_CONFIG_DIR=/home/vscode/.claude

USER vscode

RUN mkdir -p $CLAUDE_CONFIG_DIR && chmod 700 $CLAUDE_CONFIG_DIR

RUN curl -fsSL https://claude.ai/install.sh | bash
