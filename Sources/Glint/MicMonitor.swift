import CoreAudio

/// Detects whether the microphone / default input is in use — a good proxy for
/// "you're in a call or meeting". Reads only the device's run state, so it
/// needs no microphone permission and never touches audio content.
enum MicMonitor {
    static func isInputActive() -> Bool {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var defaultAddr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)

        var status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject), &defaultAddr, 0, nil, &size, &deviceID)
        guard status == noErr, deviceID != 0 else { return false }

        var running = UInt32(0)
        var runningSize = UInt32(MemoryLayout<UInt32>.size)
        var runningAddr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)

        status = AudioObjectGetPropertyData(deviceID, &runningAddr, 0, nil, &runningSize, &running)
        guard status == noErr else { return false }
        return running != 0
    }
}
