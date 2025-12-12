#!/usr/bin/env bash
set -e

PLIST="$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist"
BIN="$HOME/.local/bin/a11y-balance"

if [ -f "$PLIST" ]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm "$PLIST"
  echo "LaunchAgent rimosso."
fi

if [ -f "$BIN" ]; then
  rm "$BIN"
  echo "Binario rimosso."
fi
