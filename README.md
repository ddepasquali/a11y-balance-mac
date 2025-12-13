# a11y-balance-daemon

macOS utility that sets and keeps the default output device balance at a fixed value. Built for accessibility scenarios (unilateral hearing loss, hearing aids, unbalanced headphones): on every login and every default output-device change, the balance is re-applied automatically.

## Status and limits
- Tested only with AirPods Pro 2.
- Does not work on Mac internal speakers (the CoreAudio balance property is not exposed); other devices not verified.
- Balance is hardcoded in the source (`targetBalance` currently 0.25); change it and rebuild if you need a different value.
- Prebuilt 1.0 included: `Release/a11y-balance-mac-1.0-macos-arm64.zip` (Apple Silicon only; on Intel, rebuild from source). Double-clicking the binary runs it only for the current session; use the plist/launchctl steps below for autostart at login.

## Requirements
- macOS 13+
- Xcode toolchain / Swift 5.9+ (only if building from source)
- Permission to install a LaunchAgent in `~/Library/LaunchAgents`.

## Install (from source)
```bash
./Scripts/install.sh
```
What it does:
- Builds the binary in release.
- Copies the binary to `~/.local/bin/a11y-balance`.
- Generates `~/Library/LaunchAgents/com.a11y.balance.daemon.plist` (from `LaunchAgent/com.a11y.balance.daemon.plist.example`) and loads it with `launchctl load` so it starts at login.

## Install from release 1.0 (prebuilt, Apple Silicon)
1) Unzip (from repo root):  
   ```bash
   unzip Release/a11y-balance-mac-1.0-macos-arm64.zip -d Release
   ```
2) Install binary and create the plist (adjust `BALANCE` only if you also change source and rebuild), from repo root:  
   ```bash
   DEST_BIN="$HOME/.local/bin/a11y-balance"
   BALANCE=0.25  # 0.0=left, 0.5=center, 1.0=right
   mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents"
   cp Release/a11y-balance-mac-1.0/a11y-balance "$DEST_BIN"
   chmod +x "$DEST_BIN"
   sed "s#__BINARY_PATH__#$DEST_BIN#g; s#__BALANCE_VALUE__#$BALANCE#g" \
     Release/a11y-balance-mac-1.0/com.a11y.balance.daemon.plist.example \
    > "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist"
   launchctl unload "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist" 2>/dev/null || true
   launchctl load "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist"
   ```
If you are on Intel or the binary does not start, build from source.
Note: double-clicking the binary only runs it for the current session; to start at login, load the plist via `launchctl` as above.

## Change the default balance
1) Edit `Sources/A11yBalance/main.swift`, set `targetBalance` (0.0 = full left, 0.5 = center, 1.0 = full right).  
2) Rebuild/reinstall with `./Scripts/install.sh`.

## Uninstall
```bash
./Scripts/uninstall.sh
```
Removes the LaunchAgent and the binary from `~/.local/bin/a11y-balance`.

## Manual run
```bash
swift build -c release
./.build/release/A11yBalance
```
Leave the process running to keep balance reapplied when the default output device changes.

## Create a prebuilt 1.0 release
1) Build in release: `swift build -c release`  
2) Prepare an output folder: `mkdir -p Release/a11y-balance-mac-1.0`  
3) Copy the binary and (optional) plist example:  
   ```bash
   cp .build/release/A11yBalance Release/a11y-balance-mac-1.0/a11y-balance
   cp LaunchAgent/com.a11y.balance.daemon.plist.example Release/a11y-balance-mac-1.0/
   ```  
4) Create the zip: `cd Release && zip -r a11y-balance-mac-1.0-macos-arm64.zip a11y-balance-mac-1.0`  
Note: the binary is for Apple Silicon; on Intel rebuild on-target.

## Author
Domenico De Pasquali <br>
MSc's student in *Interaction & Experience Design*  
BSc in *Information and Communications Technologies*

## License
This project is released under the [MIT License](https://mit-license.org).
