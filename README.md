# a11y-balance-mac

Utility macOS che imposta e mantiene il bilanciamento audio del dispositivo di output di default su un valore prefissato. Nasce per esigenze di accessibilità (ipoacusia monolaterale, apparecchi acustici, cuffie con canale sbilanciato): a ogni login e a ogni cambio di dispositivo di output il bilanciamento viene riapplicato automaticamente.

## Stato e limiti
- Testato solo con AirPods Pro 2.
- Non funziona sugli speaker interni del Mac (la property CoreAudio non è esposta); altri device non sono stati verificati.
- Il bilanciamento è fisso nel codice (`targetBalance` è attualmente 0.25); per cambiarlo va ricompilato il binario.
- Release 1.0 precompilata inclusa: `Release/a11y-balance-mac-1.0-macos-arm64.zip` (solo Apple Silicon; su Intel va ricompilato).

## Requisiti
- macOS 13+
- Xcode toolchain / Swift 5.9+ (solo se compili dai sorgenti)
- Permessi per installare un LaunchAgent in `~/Library/LaunchAgents`.

## Installazione (build da sorgente)
```bash
./Scripts/install.sh
```
Cosa fa:
- Compila il binario in release.
- Copia il binario in `~/.local/bin/a11y-balance`.
- Genera `~/Library/LaunchAgents/com.a11y.balance.daemon.plist` (usando `LaunchAgent/com.a11y.balance.daemon.plist.example`) e lo carica con `launchctl load`, così parte ad ogni login.

## Installazione dalla release 1.0 (precompilata, Apple Silicon)
1) Estrai lo zip (da root repo):  
   ```bash
   unzip Release/a11y-balance-mac-1.0-macos-arm64.zip -d Release
   ```
2) Installa il binario e crea il plist (sostituisci il valore di `BALANCE` se serve), sempre dal root del repo:  
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
Se sei su Intel o se il binario non parte, usa la compilazione da sorgente.

## Cambiare il bilanciamento di default
1) Modifica `Sources/A11yBalance/main.swift` cambiando `targetBalance` (0.0 = tutto a sinistra, 0.5 = centro, 1.0 = tutto a destra).  
2) Ricompila/reinstalla con `./Scripts/install.sh`.

## Disinstallazione
```bash
./Scripts/uninstall.sh
```
Rimuove il LaunchAgent e il binario da `~/.local/bin/a11y-balance`.

## Uso manuale
```bash
swift build -c release
./.build/release/A11yBalance
```
Lascia il processo in esecuzione per avere il bilanciamento ripristinato anche quando cambi dispositivo di output di default.

## Creare una release 1.0 precompilata
1) Costruisci in release: `swift build -c release`  
2) Prepara una cartella per l’output: `mkdir -p Release/a11y-balance-mac-1.0`  
3) Copia il binario e (opzionale) il plist di esempio:  
   ```bash
   cp .build/release/A11yBalance Release/a11y-balance-mac-1.0/a11y-balance
   cp LaunchAgent/com.a11y.balance.daemon.plist.example Release/a11y-balance-mac-1.0/
   ```  
4) Crea lo zip: `cd Release && zip -r a11y-balance-mac-1.0-macos-arm64.zip a11y-balance-mac-1.0`  
Nota: il binario risultante è per Apple Silicon; su Intel va ricompilato sul target.
