#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PREFIX=${JANUS_STUDIO_PREFIX:-"${HOME}/.local"}
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/janus-studio"
SHARE_DIR="$PREFIX/share/janus-studio"

if ! command -v janus >/dev/null 2>&1; then
  echo "janus-studio: la commande janus est nécessaire pour construire l'application" >&2
  exit 1
fi

cd "$PROJECT_ROOT"
janus build --release

EXECUTABLE="$PROJECT_ROOT/target/release/janus-studio"
if [ ! -x "$EXECUTABLE" ]; then
  echo "janus-studio: exécutable de production introuvable: $EXECUTABLE" >&2
  exit 1
fi

mkdir -p "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR/assets" "$SHARE_DIR/samples"
cp "$EXECUTABLE" "$LIB_DIR/janus-studio"
cp -R "$PROJECT_ROOT/assets/." "$SHARE_DIR/assets/"
cp -R "$PROJECT_ROOT/samples/." "$SHARE_DIR/samples/"

LAUNCHER="$BIN_DIR/janus-studio"
cp "$SCRIPT_DIR/janus-studio.sh.in" "$LAUNCHER"
cp "$SCRIPT_DIR/uninstall.sh" "$BIN_DIR/janus-studio-uninstall"
chmod +x \
  "$LAUNCHER" \
  "$BIN_DIR/janus-studio-uninstall" \
  "$LIB_DIR/janus-studio"
printf '%s\n' "janus-studio" > "$SHARE_DIR/.installed-by-janus-studio"

case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *)
    echo "Ajoutez cette ligne à votre profil shell :"
    echo "  export PATH=\"${BIN_DIR}:\$PATH\""
    ;;
esac

echo "Janus Studio est installé dans $PREFIX."
echo "Lancez-le avec : janus-studio [dossier-ou-fichier]"
