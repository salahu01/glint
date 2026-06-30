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
    private static let glowRed = Color(hex: 0xFF1744)

    // Theme-driven palette.
    private var themeBase: LinearGradient {
        LinearGradient(colors: [Color(hex: model.theme.baseTop), Color(hex: model.theme.baseBottom)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    private var themeGlow: Color { Color(hex: model.theme.glow) }

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
        anticipation > 0 ? Self.glowRed : themeGlow
    }

    private var minute: Int { Calendar.current.component(.minute, from: model.date) }

    /// Depletion is shown for a focus block, when the user enables it, in Calm
    /// Mode, or whenever numerals are fully hidden (the visual is then the only
    /// time cue).
    private var depletionActive: Bool {
        model.focusActive || model.showDepletion || model.calmMode
            || model.numberVisibility == .hideAll
    }

    private var depletionColor: Color {
        model.focusActive ? Color(hex: 0x7B2FF7) : themeGlow
    }

    /// Fraction of time remaining (0…1) for the active depletion context:
    /// focus block → nudge interval → current hour.
    private var fractionRemaining: Double {
        if model.focusActive, let end = model.focusEnd, model.focusTotalSeconds > 0 {
            return max(0, min(1, end.timeIntervalSince(model.date) / model.focusTotalSeconds))
        }
        let s = Double(second), m = Double(minute)
        if model.nudgeInterval > 0 {
            let span = Double(model.nudgeInterval) * 60
            let into = m.truncatingRemainder(dividingBy: Double(model.nudgeInterval)) * 60 + s
            return max(0, min(1, 1 - into / span))
        }
        return max(0, min(1, 1 - (m * 60 + s) / 3600))
    }

    var body: some View {
        if model.timeTimerMode {
            TimeTimerFace(fraction: fractionRemaining, size: 230 * scale)
        } else {
            normalCard
        }
    }

    private var normalCard: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        return VStack(spacing: 0) {
            // Top: hours and minutes (hidden only in Hide All).
            if model.numberVisibility != .hideAll {
                Text((model.use24Hour ? Self.hourMinute24 : Self.hourMinute12).string(from: model.date))
                    .font(.system(size: 48 * scale, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .shadow(color: glowColor.opacity(0.9), radius: (6 + anticipation * 8) * scale)
            }

            // Bottom: seconds (+ AM/PM in 12-hour) — only in Full.
            if model.numberVisibility == .full {
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
                .foregroundStyle(anticipation > 0 ? .white : themeGlow)
            }

            // Focus countdown / "time sitting" digits — only in Full.
            if model.numberVisibility == .full {
                if model.focusActive {
                    HStack(spacing: 4 * scale) {
                        Image(systemName: "target")
                        Text(model.focusRemaining).monospacedDigit()
                    }
                    .font(.system(size: 14 * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x7B2FF7))
                    .padding(.top, 2 * scale)
                } else if model.stopwatchActive {
                    HStack(spacing: 4 * scale) {
                        Image(systemName: model.stopwatchRunning ? "stopwatch.fill" : "stopwatch")
                        Text(model.stopwatchText).monospacedDigit()
                    }
                    .font(.system(size: 14 * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x2EC4B6))
                    .padding(.top, 2 * scale)
                } else if model.showElapsed {
                    HStack(spacing: 4 * scale) {
                        Image(systemName: "hourglass")
                        Text(model.elapsedText)
                    }
                    .font(.system(size: 13 * scale, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 2 * scale)
                }
            }

            // Disk depletion, or a sizing placeholder when all numerals are hidden.
            if depletionActive && model.depletionStyle == .disk {
                TimerDisk(fraction: fractionRemaining, color: depletionColor, diameter: 76 * scale)
                    .padding(.top, model.numberVisibility == .hideAll ? 0 : 6 * scale)
            } else if model.numberVisibility == .hideAll {
                Color.clear.frame(width: 104 * scale, height: 58 * scale)
            }
        }
        .fixedSize()
        .padding(.horizontal, 24 * scale)
        .padding(.vertical, 14 * scale)
        // Order matters: warm wash sits in front of the base, behind the text.
        .background(Self.warnGradient.opacity(anticipation * model.intensity.scale), in: shape)
        .background(themeBase, in: shape)                               // themed base
        .overlay(shape.fill(flashGradient).opacity(flashOpacity))       // burst flash
        .overlay(
            shape.strokeBorder(glowColor.opacity(0.4 + anticipation * 0.6),
                               lineWidth: 1.5)
        )
        // Perimeter-ring depletion (idea 1+2).
        .overlay {
            if depletionActive && model.depletionStyle == .ring {
                TimerRing(fraction: fractionRemaining,
                          color: depletionColor,
                          lineWidth: (model.focusActive ? 4 : 2.5) * scale,
                          cornerRadius: 20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: anticipation)
        // Calm Mode suppresses the alarm bursts — depletion + wash carry the cue.
        .onChange(of: model.minuteTick) { _ in
            if !model.calmMode { flash(Self.minuteFlash, peak: 0.9 * model.intensity.scale, duration: 0.8) }
        }
        .onChange(of: model.hourTick) { _ in
            if !model.calmMode { flash(Self.hourFlash, peak: 0.95 * model.intensity.scale, duration: 1.4) }
        }
        .onChange(of: model.nudgeTick) { _ in
            if !model.calmMode { nudge(peak: 0.95 * model.intensity.scale) }
        }
        .onChange(of: model.focusEndedTick) { _ in
            nudge(peak: model.calmMode ? 0.4 : max(0.85, model.intensity.scale))
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
