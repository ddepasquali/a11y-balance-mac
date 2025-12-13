# a11y-balance-daemon

macOS daemon that sets and keeps the default output device balance at a fixed value. Built for accessibility scenarios (unilateral hearing loss, hearing aids, unbalanced headphones): on every login and every default output-device change, the balance is re-applied automatically.

> v2.0.0 (current, untagged): CLI/LaunchAgent flow with configurable balance, ready to be embedded or shipped by third-party apps or installers.
> This README describes the current v2.0.0 flow; legacy v1.0.0 prebuilt instructions are kept in a separate section below.

## Status and limits
- Tested only with AirPods Pro 2.
- Does not work on Mac internal speakers (the CoreAudio balance property is not exposed); other devices not verified.
- Default balance is 0.25; override it without rebuilding via the CLI flag `--balance <0.0-1.0>` or by setting `BALANCE=<value>` when running `./Scripts/install.sh` (the value is stored in the LaunchAgent plist).
- Prebuilt v1.0.0 included: `Release/a11y-balance-mac-1.0-macos-arm64.zip` (Apple Silicon only, balance fixed at 0.25). Double-clicking the binary runs it only for the current session; use the plist/launchctl steps below for autostart at login.

## Requirements
- macOS 13+
- Xcode toolchain / Swift 5.9+ (only if building from source)
- Permission to install a LaunchAgent in `~/Library/LaunchAgents`.

## Versions
- `v1.0.0` - first public build, balance compiled to 0.25; Apple Silicon prebuilt under `Release/a11y-balance-mac-1.0-macos-arm64.zip`. Changing the balance requires editing the source and rebuilding.
- `v2.0.0` (current, untagged) - CLI `--balance` support and templated LaunchAgent; third-party apps/installers can embed the daemon and preconfigure balance without touching the source. Install via `./Scripts/install.sh` (optionally `BALANCE=0.35 ./Scripts/install.sh`) to set the persisted balance; no new prebuilt released yet.

## Install v2.0.0 (current, from source)
Default balance is 0.25. Override it without rebuilding by passing `BALANCE`:
```bash
./Scripts/install.sh                  # installs with balance=0.25
BALANCE=0.35 ./Scripts/install.sh     # installs with balance=0.35
```
What it does:
- Builds the binary in release.
- Copies the binary to `~/.local/bin/a11y-balance`.
- Generates `~/Library/LaunchAgents/com.a11y.balance.daemon.plist` (from `LaunchAgent/com.a11y.balance.daemon.plist.example`) with `--balance <BALANCE>` and loads it with `launchctl load` so it starts at login (your chosen balance is persisted there).

## Install legacy v1.0.0 (prebuilt, Apple Silicon)
This is the tagged `v1.0.0` build with balance fixed at 0.25 (no CLI override). For a different balance, use the v2.0.0 source install above.
1) Unzip (from repo root):  
   ```bash
   unzip Release/a11y-balance-mac-1.0-macos-arm64.zip -d Release
   ```
2) Install binary and create the plist (the `BALANCE` placeholder is kept for consistency, but the v1.0.0 binary always uses 0.25), from repo root:  
   ```bash
   DEST_BIN="$HOME/.local/bin/a11y-balance"
   BALANCE=0.25  # Placeholder for the plist; the v1.0.0 binary always uses 0.25
   mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents"
   cp Release/a11y-balance-mac-1.0/a11y-balance "$DEST_BIN"
   chmod +x "$DEST_BIN"
   sed "s#__BINARY_PATH__#$DEST_BIN#g; s#__BALANCE_VALUE__#$BALANCE#g" \
     Release/a11y-balance-mac-1.0/com.a11y.balance.daemon.plist.example \
    > "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist"
   launchctl unload "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist" 2>/dev/null || true
   launchctl load "$HOME/Library/LaunchAgents/com.a11y.balance.daemon.plist"
   ```
If you are on Intel or need a different balance, build from source. Double-clicking the binary only runs it for the current session; to start at login, load the plist via `launchctl` as above.

## Change the default balance (v2.0.0)
- Reinstall with a new value: `BALANCE=0.6 ./Scripts/install.sh` (persists in the LaunchAgent plist).
- For manual runs, pass the flag: `./.build/release/A11yBalance --balance 0.6`.
- To change the fallback default used when no flag is passed, edit `defaultBalance` in `Sources/A11yBalance/main.swift` and rebuild.

## Uninstall
```bash
./Scripts/uninstall.sh
```
Removes the LaunchAgent and the binary from `~/.local/bin/a11y-balance`.

## Manual run (v2.0.0)
```bash
swift build -c release
./.build/release/A11yBalance --balance 0.25
```
Leave the process running to keep balance reapplied when the default output device changes.

## Create a prebuilt release archive
Example with folder/zip name `a11y-balance-mac-1.0`:
1) Build in release: `swift build -c release`  
2) Prepare an output folder: `mkdir -p Release/a11y-balance-mac-1.0`  
3) Copy the binary and (optional) plist example:  
   ```bash
   cp .build/release/A11yBalance Release/a11y-balance-mac-1.0/a11y-balance
   cp LaunchAgent/com.a11y.balance.daemon.plist.example Release/a11y-balance-mac-1.0/
   ```  
4) Create the zip: `cd Release && zip -r a11y-balance-mac-1.0-macos-arm64.zip a11y-balance-mac-1.0`  
Rename the folder/zip to match the version you are packaging. Build on Apple Silicon for Apple Silicon; on Intel rebuild on-target.

## Author
Domenico De Pasquali <br>
MSc's student in *Interaction & Experience Design*  
BSc in *Information and Communications Technologies*

## License
This project is released under the [MIT License](https://mit-license.org).
