#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PREFIX=${JANUS_STUDIO_PREFIX:-"${HOME}/.local"}
JANUS_BIN=${JANUS:-janus}
MINIMUM_JANUS_VERSION=0.21.0
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/janus-studio"
SHARE_DIR="$PREFIX/share/janus-studio"

if ! command -v "$JANUS_BIN" >/dev/null 2>&1; then
  echo "janus-studio: compilateur Janus introuvable: $JANUS_BIN" >&2
  echo "Définissez JANUS=/chemin/vers/janus ou ajoutez-le au PATH." >&2
  exit 1
fi

JANUS_VERSION_OUTPUT=$("$JANUS_BIN" --version 2>/dev/null) || {
  echo "janus-studio: impossible de déterminer la version de $JANUS_BIN" >&2
  exit 1
}
JANUS_VERSION=${JANUS_VERSION_OUTPUT#janus }
JANUS_VERSION=${JANUS_VERSION%%+*}
JANUS_VERSION=${JANUS_VERSION%%-*}

version_is_supported() (
  old_ifs=$IFS
  IFS=.
  set -- $1
  IFS=$old_ifs
  major=${1:-0}
  minor=${2:-0}
  patch=${3:-0}

  case "$major.$minor.$patch" in
    *[!0-9.]*) return 1 ;;
  esac

  [ "$major" -gt 0 ] ||
    { [ "$major" -eq 0 ] && [ "$minor" -gt 21 ]; } ||
    { [ "$major" -eq 0 ] && [ "$minor" -eq 21 ] && [ "$patch" -ge 0 ]; }
)

if ! version_is_supported "$JANUS_VERSION"; then
  echo "janus-studio: Janus $MINIMUM_JANUS_VERSION ou plus récent est requis; version trouvée: $JANUS_VERSION" >&2
  echo "Définissez JANUS=/chemin/vers/janus-$MINIMUM_JANUS_VERSION ou mettez le PATH à jour." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
"$JANUS_BIN" build --release

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
