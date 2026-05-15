#!/bin/sh
# CTCC Installer for Linux/Mac
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

DEST="/usr/local/bin/ctcc"

printf "${C}Downloading ctcc...\n${RST}"
curl -fsSL "https://abc6712.netlify.app/ctcc" -o "$DEST"
chmod +x "$DEST"

printf "${GREEN}Done! You can now run:\n${RST}"
echo ""
echo "  ctcc run           — open a room"
echo "  ctcc join <IP>     — join a room"
echo ""
