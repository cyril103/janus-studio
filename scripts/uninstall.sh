#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -n "${JANUS_STUDIO_PREFIX:-}" ]; then
  PREFIX=$JANUS_STUDIO_PREFIX
elif [ -f "$SCRIPT_DIR/../share/janus-studio/.installed-by-janus-studio" ]; then
  PREFIX=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
else
  PREFIX="${HOME}/.local"
fi
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/janus-studio"
SHARE_DIR="$PREFIX/share/janus-studio"
MARKER="$SHARE_DIR/.installed-by-janus-studio"

if [ ! -f "$MARKER" ]; then
  echo "Janus Studio n'est pas installé dans $PREFIX."
  exit 0
fi

rm -f -- "$BIN_DIR/janus-studio" "$BIN_DIR/janus-studio-uninstall"
rm -rf -- "$LIB_DIR" "$SHARE_DIR"

rmdir "$PREFIX/lib" "$PREFIX/share" "$BIN_DIR" "$PREFIX" 2>/dev/null || true

echo "Janus Studio a été désinstallé de $PREFIX."
echo "Si vous aviez ajouté $BIN_DIR à votre profil shell, vous pouvez retirer cette ligne."
