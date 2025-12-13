#!/usr/bin/env bash
set -e

# Cartella del repo (Scripts/..)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Repo dir: $REPO_DIR"

# 1) Build in release
cd "$REPO_DIR"
swift build -c release

TARGET_NAME="A11yBalance"
BINARY_PATH="$REPO_DIR/.build/release/$TARGET_NAME"

if [ ! -f "$BINARY_PATH" ]; then
  echo "Errore: binario non trovato in $BINARY_PATH"
  exit 1
fi

# 2) Copia il binario in una posizione stabile (~/.local/bin/a11y-balance)
INSTALL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_BIN_DIR"
INSTALL_BIN_PATH="$INSTALL_BIN_DIR/a11y-balance"

cp "$BINARY_PATH" "$INSTALL_BIN_PATH"
chmod +x "$INSTALL_BIN_PATH"

echo "Binario installato in: $INSTALL_BIN_PATH"

# 3) Prepara il LaunchAgent, con balance configurabile
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

PLIST_SRC="$REPO_DIR/LaunchAgent/com.a11y.balance.daemon.plist.example"
PLIST_DST="$LAUNCH_AGENTS_DIR/com.a11y.balance.daemon.plist"

# Default balance se non viene passato BALANCE esternamente
# 0.0 = tutto a sinistra, 0.5 = centro, 1.0 = tutto a destra
BALANCE_VALUE="${BALANCE:-0.25}"

# Sostituisci i placeholder nel template
sed "s#__BINARY_PATH__#$INSTALL_BIN_PATH#g; s#__BALANCE_VALUE__#$BALANCE_VALUE#g" "$PLIST_SRC" > "$PLIST_DST"

echo "Plist installato in: $PLIST_DST (balance=$BALANCE_VALUE)"

# 4) Ricarica il LaunchAgent
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load "$PLIST_DST"

echo "LaunchAgent caricato. Il demone partirà ad ogni login."