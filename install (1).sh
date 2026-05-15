#!/bin/sh
# CTCC Installer for Linux/Mac/Android (Termux)
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

# Pick install dir based on environment
if [ -n "$TERMUX_VERSION" ]; then
  # Termux — use its own bin dir, no root needed
  DEST="$PREFIX/bin/ctcc"
elif [ -w "/usr/local/bin" ]; then
  # Already writable (no sudo needed)
  DEST="/usr/local/bin/ctcc"
else
  # Standard Linux/Mac — need sudo
  DEST="/usr/local/bin/ctcc"
  USE_SUDO=1
fi

TMP="$(mktemp)"

printf "${C}Downloading ctcc...\n${RST}"
curl -fsSL "https://abc6712.netlify.app/ctcc" -o "$TMP"
chmod +x "$TMP"

printf "${C}Installing to $DEST...\n${RST}"
if [ "$USE_SUDO" = "1" ]; then
  sudo mv "$TMP" "$DEST"
else
  mv "$TMP" "$DEST"
fi

printf "${GREEN}Done! You can now run:\n${RST}"
echo ""
echo "  ctcc run           — open a room"
echo "  ctcc join <IP>     — join a room"
echo ""
