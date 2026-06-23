import SwiftUI

extension Color {
    /// Build a color from a 0xRRGGBB literal.
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// The floating clock face: big `H:MM` on top, smaller `SS` + `AM`/`PM` below.
///
/// High-contrast, high-saturation states so a time change grabs the eye:
///  - Normal: deep indigo card, white digits with a cyan glow.
///  - Seconds 50–59: a warm amber→red wash fades in and the glow reddens.
///  - Minute change: a teal/cyan burst flash.
///  - Hour change: a bigger, longer orange→magenta burst.
struct ClockView: View {
    @EnvironmentObject var model: ClockModel

    @State private var flashOpacity: Double = 0
    @State private var flashGradient = ClockView.minuteFlash

    // Palette
    private static let baseGradient = LinearGradient(
        colors: [Color(hex: 0x1A1A2E), Color(hex: 0x16213E)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    private static let warnGradient = LinearGradient(
        colors: [Color(hex: 0xFF9F1C), Color(hex: 0xE71D36)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    private static let minuteFlash = LinearGradient(
        colors: [Color(hex: 0x2EC4B6), Color(hex: 0x00F5D4)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    private static let hourFlash = LinearGradient(
        colors: [Color(hex: 0xFB5607), Color(hex: 0xFF006E)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    private static let nudgeFlash = LinearGradient(
        colors: [Color(hex: 0x7B2FF7), Color(hex: 0x00F5D4)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    private static let glowCyan = Color(hex: 0x00F5D4)
    private static let glowRed = Color(hex: 0xFF1744)

    private static let hourMinute12 = makeFormatter("h:mm")
    private static let hourMinute24 = makeFormatter("H:mm")
    private static let secondsFormatter = makeFormatter("ss")
    private static let periodFormatter = makeFormatter("a")

    private static func makeFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f
    }

    private var second: Int { Calendar.current.component(.second, from: model.date) }
    private var scale: CGFloat { CGFloat(model.size.scale) }

    /// 0 until :50, then ramps 0.1 → 1.0 across the final ten seconds.
    private var anticipation: Double {
        second >= 50 ? Double(second - 49) / 10.0 : 0
    }

    private var glowColor: Color {
        anticipation > 0 ? Self.glowRed : Self.glowCyan
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        VStack(spacing: 0) {
            // Top: hours and minutes, large.
            Text((model.use24Hour ? Self.hourMinute24 : Self.hourMinute12).string(from: model.date))
                .font(.system(size: 48 * scale, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .shadow(color: glowColor.opacity(0.9), radius: (6 + anticipation * 8) * scale)

            // Bottom: seconds (+ AM/PM in 12-hour), in the accent color.
            HStack(spacing: 8 * scale) {
                Text(Self.secondsFormatter.string(from: model.date))
                    .monospacedDigit()
                if !model.use24Hour {
                    Text(Self.periodFormatter.string(from: model.date))
                }
                Image(systemName: model.soundSuppressed ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 13 * scale))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .font(.system(size: 30 * scale, weight: .bold, design: .rounded))
            .foregroundStyle(anticipation > 0 ? .white : Self.glowCyan)

            // Focus block countdown (takes priority over the sitting readout).
            if model.focusActive {
                HStack(spacing: 4 * scale) {
                    Image(systemName: "target")
                    Text(model.focusRemaining)
                        .monospacedDigit()
                }
                .font(.system(size: 14 * scale, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: 0x7B2FF7))
                .padding(.top, 2 * scale)
            } else if model.showElapsed {
                // Optional: "time sitting" since the session started.
                HStack(spacing: 4 * scale) {
                    Image(systemName: "hourglass")
                    Text(model.elapsedText)
                }
                .font(.system(size: 13 * scale, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 2 * scale)
            }
        }
        .fixedSize()
        .padding(.horizontal, 24 * scale)
        .padding(.vertical, 14 * scale)
        // Order matters: warm wash sits in front of the base, behind the text.
        .background(Self.warnGradient.opacity(anticipation * model.intensity.scale), in: shape)
        .background(Self.baseGradient, in: shape)                       // solid base
        .overlay(shape.fill(flashGradient).opacity(flashOpacity))       // burst flash
        .overlay(
            shape.strokeBorder(glowColor.opacity(0.4 + anticipation * 0.6),
                               lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.3), value: anticipation)
        .onChange(of: model.minuteTick) { _ in
            flash(Self.minuteFlash, peak: 0.9 * model.intensity.scale, duration: 0.8)
        }
        .onChange(of: model.hourTick) { _ in
            flash(Self.hourFlash, peak: 0.95 * model.intensity.scale, duration: 1.4)
        }
        .onChange(of: model.nudgeTick) { _ in
            nudge(peak: 0.95 * model.intensity.scale)
        }
        .onChange(of: model.focusEndedTick) { _ in
            nudge(peak: max(0.85, model.intensity.scale))
        }
        .help(model.soundSuppressed ? "Click to unmute ticking" : "Click to mute ticking")
    }

    /// Interval-nudge blink: pulse the whole card several times so a scheduled
    /// time-check is impossible to miss. Even repeat count settles back at 0.
    private func nudge(peak: Double) {
        flashGradient = Self.nudgeFlash
        flashOpacity = 0
        withAnimation(.easeInOut(duration: 0.22).repeatCount(6, autoreverses: true)) {
            flashOpacity = peak
        }
    }

    /// Snap the flash overlay to full color, then fade it back to transparent.
    private func flash(_ gradient: LinearGradient, peak: Double, duration: Double) {
        flashGradient = gradient
        flashOpacity = peak
        withAnimation(.easeOut(duration: duration)) {
            flashOpacity = 0
        }
    }
}
