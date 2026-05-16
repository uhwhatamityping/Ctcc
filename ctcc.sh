#!/bin/sh
# CTCC Installer for Linux/Mac/Android (with Cloudflare Tunnel)
# Run with: curl -fsSL https://abc6712.netlify.app/install.sh | sh

set -e

GREEN='\033[1;32m'
RED='\033[1;31m'
Y='\033[1;33m'
C='\033[1;36m'
RST='\033[0m'

echo ""
printf "${Y}CTCC — Computer to Computer Communication\n${RST}"
printf "${Y}Installer\n${RST}"
echo ""

if ! command -v python3 >/dev/null 2>&1; then
  printf "${RED}Error: python3 is required but not found.\n${RST}"
  if [ -n "$TERMUX_VERSION" ]; then
    printf "${RED}Install it with: pkg install python\n${RST}"
  else
    printf "${RED}Install it from https://python.org\n${RST}"
  fi
  exit 1
fi

# Check for cloudflared
if ! command -v cloudflared >/dev/null 2>&1; then
  printf "${C}Installing cloudflared...\n${RST}"
  
  ARCH=$(uname -m)
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  
  # Map architectures
  case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l) ARCH="arm" ;;
  esac
  
  # Download from official Cloudflare CDN
  if [ "$OS" = "darwin" ]; then
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz"
  else
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.tgz"
  fi
  
  TMP=$(mktemp -d)
  curl -fsSL "$CLOUDFLARED_URL" -o "$TMP/cloudflared.tgz" || {
    printf "${RED}Failed to download cloudflared. Check your internet connection.\n${RST}"
    rm -rf "$TMP"
    exit 1
  }
  
  tar xzf "$TMP/cloudflared.tgz" -C "$TMP"
  
  if [ -n "$TERMUX_VERSION" ]; then
    mv "$TMP/cloudflared" "$PREFIX/bin/"
  else
    sudo mv "$TMP/cloudflared" /usr/local/bin/
    sudo chmod +x /usr/local/bin/cloudflared
  fi
  
  rm -rf "$TMP"
  printf "${GREEN}cloudflared installed!\n${RST}"
fi

# Install ctcc
if [ -n "$TERMUX_VERSION" ]; then
  DEST="$PREFIX/bin/ctcc"
else
  DEST="/usr/local/bin/ctcc"
fi

TMP="$(mktemp)"

printf "${C}Downloading ctcc...\n${RST}"
curl -fsSL "https://abc6712.netlify.app/ctcc" -o "$TMP"
chmod +x "$TMP"

printf "${C}Installing to $DEST...\n${RST}"
if [ -n "$TERMUX_VERSION" ]; then
  mv "$TMP" "$DEST"
else
  sudo mv "$TMP" "$DEST"
fi

printf "${GREEN}Done! You can now run:\n${RST}"
echo ""
echo "  ctcc server           — start the relay server"
echo "  ctcc connect          — connect via Cloudflare Tunnel"
echo "  ctcc join <addr>      — connect locally"
echo ""
