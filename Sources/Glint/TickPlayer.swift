import AVFoundation

/// Generates and plays two short "click" sounds — a higher TICK and a lower
/// TOCK — so the audible tick changes every second, like a mechanical clock.
///
/// No audio asset files are used: both clicks are synthesized at init as
/// short, exponentially-decaying sine bursts written into PCM buffers.
///
/// Audio is best-effort: if the format/buffers/engine can't be set up, the
/// clock keeps running silently rather than crashing.
final class TickPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let tickBuffer: AVAudioPCMBuffer?
    private let tockBuffer: AVAudioPCMBuffer?
    private let chimeBuffer: AVAudioPCMBuffer?
    private var ready = false

    init() {
        let sampleRate = 44_100.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            tickBuffer = nil
            tockBuffer = nil
            chimeBuffer = nil
            NSLog("TickPlayer: could not create audio format; ticking disabled")
            return
        }

        // TICK: higher pitch, very short. TOCK: lower pitch, slightly longer.
        tickBuffer = TickPlayer.makeClick(format: format, frequency: 1_000, duration: 0.045, decay: 90)
        tockBuffer = TickPlayer.makeClick(format: format, frequency: 750, duration: 0.060, decay: 70)
        // CHIME: bell-like tone for minute/hour roll-over (much more audible).
        chimeBuffer = TickPlayer.makeChime(format: format, frequency: 880, duration: 0.7)
        guard tickBuffer != nil, tockBuffer != nil else {
            NSLog("TickPlayer: could not synthesize click buffers; ticking disabled")
            return
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
            player.play()
            ready = true
        } catch {
            NSLog("TickPlayer: audio engine failed to start: \(error)")
        }
    }

    /// Plays TICK on odd seconds, TOCK on even seconds.
    /// `scheduleBuffer` is safe to call from any thread while playing.
    func play(forSecond second: Int) {
        guard ready, engine.isRunning else { return }
        guard let buffer = (second % 2 == 0) ? tockBuffer : tickBuffer else { return }
        player.scheduleBuffer(buffer, completionHandler: nil)
    }

    /// Plays a bell chime `times` in a row (queued sequentially), so a minute
    /// (1), hour (2) and interval nudge (3) each sound distinct.
    func playChime(times: Int = 1) {
        guard ready, engine.isRunning, let chimeBuffer else { return }
        for _ in 0..<max(1, times) {
            player.scheduleBuffer(chimeBuffer, completionHandler: nil)
        }
    }

    /// Builds a bell-like chime: fundamental plus quieter harmonics, with a
    /// slow decay so it rings rather than clicks.
    private static func makeChime(
        format: AVAudioFormat,
        frequency: Double,
        duration: Double
    ) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return nil }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = exp(-t * 5.0)
            let tone = sin(2.0 * .pi * frequency * t)
                + 0.5 * sin(2.0 * .pi * frequency * 2 * t)
                + 0.25 * sin(2.0 * .pi * frequency * 3 * t)
            samples[i] = Float(tone * envelope * 0.25)
        }
        return buffer
    }

    /// Builds one click: a sine wave at `frequency` shaped by an exponential
    /// decay envelope (`decay` = how fast it fades) so it sounds percussive.
    private static func makeClick(
        format: AVAudioFormat,
        frequency: Double,
        duration: Double,
        decay: Double
    ) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return nil }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = exp(-t * decay)
            let value = sin(2.0 * .pi * frequency * t) * envelope
            samples[i] = Float(value * 0.5) // 0.5 = headroom, avoids clipping
        }
        return buffer
    }
}
