#!/bin/sh
# CTCC Installer for Linux/Mac (with ngrok)
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
  printf "${RED}Install it from https://python.org\n${RST}"
  exit 1
fi

# Check for ngrok
if ! command -v ngrok >/dev/null 2>&1; then
  printf "${C}Installing ngrok...\n${RST}"
  NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-$(uname -s)-$(uname -m).tgz"
  TMP=$(mktemp)
  curl -fsSL "$NGROK_URL" -o "$TMP"
  tar xzf "$TMP" -C /tmp
  sudo mv /tmp/ngrok /usr/local/bin/
  rm "$TMP"
fi

TMP="$(mktemp)"
DEST="/usr/local/bin/ctcc"

printf "${C}Downloading ctcc...\n${RST}"
curl -fsSL "https://abc6712.netlify.app/ctcc" -o "$TMP"
chmod +x "$TMP"

printf "${C}Installing to $DEST...\n${RST}"
sudo mv "$TMP" "$DEST"

printf "${GREEN}Done! You can now run:\n${RST}"
echo ""
echo "  ctcc server           — start the relay server"
echo "  ctcc connect <addr>   — connect via ngrok"
echo "  ctcc join <addr>      — connect locally"
echo ""
