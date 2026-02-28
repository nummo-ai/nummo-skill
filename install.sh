#!/bin/sh
set -e

REPO="nummo-ai/nummo-banking"
SKILL_REPO="nummo-ai/nummo-skill"
BIN_DIR="/usr/local/bin"
SKILL_DIR="$HOME/.openclaw/skills/nummo"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

case "$OS" in
  linux|darwin) ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Get latest release version from public skill repo
echo "Fetching latest release..."
VERSION=$(curl -fsSL "https://raw.githubusercontent.com/$SKILL_REPO/main/version.txt" | tr -d '[:space:]')

if [ -z "$VERSION" ]; then
  echo "Failed to fetch latest version"
  exit 1
fi

echo "Installing nummo $VERSION..."

# Download binary
BINARY="nummo-$OS-$ARCH"
URL="https://github.com/$SKILL_REPO/releases/download/$VERSION/$BINARY"

TMP=$(mktemp)
curl -fsSL "$URL" -o "$TMP"
chmod +x "$TMP"

# Install binary
if [ -w "$BIN_DIR" ]; then
  mv "$TMP" "$BIN_DIR/nummo"
else
  sudo mv "$TMP" "$BIN_DIR/nummo"
fi

# Install SKILL.md
mkdir -p "$SKILL_DIR"
curl -fsSL "https://raw.githubusercontent.com/$SKILL_REPO/main/SKILL.md" -o "$SKILL_DIR/SKILL.md"

echo ""
echo "nummo $VERSION installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Run 'nummo auth signup <email>' to create an account"
echo "  2. Run 'nummo accounts connect' to connect your bank"
echo ""
