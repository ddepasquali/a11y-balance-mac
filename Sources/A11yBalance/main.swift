import Foundation
import CoreAudio
import AudioToolbox

// Bilanciamento fisso scelto dall'utente
// 0.0 = full left, 0.5 = center, 1.0 = full right
let targetBalance: Float32 = 0.25

// MARK: - Helpers CoreAudio

func getDefaultOutputDevice() -> AudioDeviceID? {
    var deviceID = AudioDeviceID(0)
    var size = UInt32(MemoryLayout.size(ofValue: deviceID))

    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &address,
        0,
        nil,
        &size,
        &deviceID
    )

    if status != noErr {
        fputs("Errore getDefaultOutputDevice: \(status)\n", stderr)
        return nil
    }

    return deviceID
}

func setBalance(of deviceID: AudioDeviceID, to balance: Float32) {
    // Property address per il balance virtuale
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainBalance,
        mScope: kAudioObjectPropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
    )

    // 1) La property esiste?
    if !AudioObjectHasProperty(deviceID, &address) {
        fputs("Balance non supportato su questo device (property mancante)\n", stderr)
        return
    }

    // 2) È settabile?
    var isSettable = DarwinBoolean(false)
    let infoErr = AudioObjectIsPropertySettable(deviceID, &address, &isSettable)
    if infoErr != noErr || !isSettable.boolValue {
        fputs("Balance non settabile su questo device (err=\(infoErr))\n", stderr)
        return
    }

    // 3) Set effettivo
    var value = balance
    let size = UInt32(MemoryLayout.size(ofValue: value))

    let status = AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &value)
    if status != noErr {
        fputs("Errore setBalance (\(status))\n", stderr)
    }
}

func applyBalanceToDefaultDevice() {
    guard let deviceID = getDefaultOutputDevice() else {
        fputs("Impossibile ottenere il device di output di default\n", stderr)
        return
    }

    setBalance(of: deviceID, to: targetBalance)
}

// MARK: - Listener su cambio device di output

func startDefaultOutputWatcher() {
    let systemObjectID = AudioObjectID(kAudioObjectSystemObject)

    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let queue = DispatchQueue.global(qos: .background)

    let status = AudioObjectAddPropertyListenerBlock(
        systemObjectID,
        &address,
        queue
    ) { _, _ in
        applyBalanceToDefaultDevice()
    }

    if status != noErr {
        fputs("Errore AudioObjectAddPropertyListenerBlock: \(status)\n", stderr)
    }
}

// MARK: - Entry point

applyBalanceToDefaultDevice()
startDefaultOutputWatcher()
RunLoop.current.run()
