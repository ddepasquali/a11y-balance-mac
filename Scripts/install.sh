#!/usr/bin/env bash
set -e

# Cartella del repo
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Repo dir: $REPO_DIR"

TARGET_NAME="A11yBalance"

# 1) Build in release
cd "$REPO_DIR"
swift build -c release

BINARY_PATH="$REPO_DIR/.build/release/$TARGET_NAME"

if [ ! -f "$BINARY_PATH" ]; then
  echo "Errore: binario non trovato in $BINARY_PATH"
  exit 1
fi

# 2) Copia il binario in una posizione stabile
INSTALL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_BIN_DIR"
INSTALL_BIN_PATH="$INSTALL_BIN_DIR/a11y-balance"

cp "$BINARY_PATH" "$INSTALL_BIN_PATH"
chmod +x "$INSTALL_BIN_PATH"

echo "Binario installato in: $INSTALL_BIN_PATH"

# 3) Prepara il LaunchAgent
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

PLIST_SRC="$REPO_DIR/LaunchAgent/com.a11y.balance.daemon.plist.example"
PLIST_DST="$LAUNCH_AGENTS_DIR/com.a11y.balance.daemon.plist"

# Esempio: BALANCE=0.3 ./Scripts/install.sh
BALANCE_VALUE="${BALANCE:-0.0}"

sed "s#__BINARY_PATH__#$INSTALL_BIN_PATH#g; s#__BALANCE_VALUE__#$BALANCE_VALUE#g" "$PLIST_SRC" > "$PLIST_DST"

echo "Plist installato in: $PLIST_DST (balance=$BALANCE_VALUE)"

# 4) Carica il LaunchAgent
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load "$PLIST_DST"

echo "LaunchAgent caricato. Il demone partirà ad ogni login."
