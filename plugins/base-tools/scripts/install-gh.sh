#!/bin/bash

set -euo pipefail

TEMP_DIR=""

cleanup() {
  if [[ -n "${TEMP_DIR}" ]] && [[ -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}

trap cleanup EXIT

# すでにインストール済みならスキップ
if command -v gh &> /dev/null; then
  echo "gh is already installed: $(gh --version)"
  exit 0
fi

VERSION="${GH_SETUP_VERSION:-2.83.2}"
if [[ ! "${VERSION}" =~ ^[0-9.]+$ ]]; then
  echo "Error: Invalid version format: ${VERSION}" >&2
  exit 1
fi

# GitHub CLIのリリースはx86_64をamd64、aarch64をarm64として配布しているため変換
ARCH=$(uname -m)
case "${ARCH}" in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64|arm64)
    ARCH="arm64"
    ;;
  *)
    echo "Error: Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

# GitHub CLIのアセット名はOS表記が異なり、配布形式もOS毎に異なる
RAW_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "${RAW_OS}" in
  linux)
    OS="linux"
    EXT="tar.gz"
    ;;
  darwin)
    OS="macOS"
    EXT="zip"
    ;;
  *)
    echo "Error: Unsupported OS: ${RAW_OS}" >&2
    exit 1
    ;;
esac

URL="https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_${OS}_${ARCH}.${EXT}"

echo "Downloading gh ${VERSION} for ${OS}/${ARCH}..."

TEMP_DIR=$(mktemp -d)

cd "${TEMP_DIR}"
ARCHIVE="gh_${VERSION}_${OS}_${ARCH}.${EXT}"
if ! curl -fsSL "${URL}" -o "${ARCHIVE}"; then
  echo "Error: Failed to download from ${URL}" >&2
  exit 1
fi

# チェックサム検証
CHECKSUMS="gh_${VERSION}_checksums.txt"
if ! curl -fsSL "https://github.com/cli/cli/releases/download/v${VERSION}/${CHECKSUMS}" -o "${CHECKSUMS}"; then
  echo "Error: Failed to download checksums file" >&2
  exit 1
fi
EXPECTED_LINE=$(grep " ${ARCHIVE}$" "${CHECKSUMS}" || true)
if [[ -z "${EXPECTED_LINE}" ]]; then
  echo "Error: Checksum entry not found for ${ARCHIVE}" >&2
  exit 1
fi
echo "Verifying checksum..."
if command -v sha256sum >/dev/null 2>&1; then
  echo "${EXPECTED_LINE}" | sha256sum -c -
else
  echo "${EXPECTED_LINE}" | shasum -a 256 -c -
fi

if [[ "${EXT}" == "tar.gz" ]]; then
  if ! tar -xzf "gh.${EXT}"; then
    echo "Error: Failed to extract gh.${EXT}" >&2
    exit 1
  fi
else
  if ! unzip -q "gh.${EXT}"; then
    echo "Error: Failed to extract gh.${EXT}" >&2
    exit 1
  fi
fi

GH_BINARY="gh_${VERSION}_${OS}_${ARCH}/bin/gh"
if [[ ! -f "${GH_BINARY}" ]]; then
  echo "Error: gh binary not found in downloaded archive at expected path: ./${GH_BINARY}" >&2
  exit 1
fi

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "${INSTALL_DIR}"

cp "${GH_BINARY}" "${INSTALL_DIR}/gh"
chmod 755 "${INSTALL_DIR}/gh"

echo "gh installed to ${INSTALL_DIR}/gh"

export PATH="${INSTALL_DIR}:${PATH}"

# セッション間でPATHを維持するため環境ファイルに永続化
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  if ! grep -q "export PATH=.*${INSTALL_DIR}" "${CLAUDE_ENV_FILE}" 2>/dev/null; then
    echo "export PATH=\"${INSTALL_DIR}:\${PATH}\"" >> "${CLAUDE_ENV_FILE}"
    echo "PATH setting persisted to ${CLAUDE_ENV_FILE}"
  fi
fi

# トークンが設定されている場合はGit認証をセットアップ
if [[ -n "${GH_TOKEN:-}" ]] || [[ -n "${GITHUB_TOKEN:-}" ]]; then
  echo "Setting up Git authentication..."
  gh auth setup-git
fi

echo "gh installation completed successfully!"
gh --version
