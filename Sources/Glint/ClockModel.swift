import Foundation
import Combine

/// A color theme: the card's base gradient plus the accent/glow color.
/// (The change flashes — teal minute, orange hour, violet nudge — stay constant
/// so their meaning is always recognizable.)
struct ClockTheme {
    let name: String
    let baseTop: UInt
    let baseBottom: UInt
    let glow: UInt
}

let clockThemes: [ClockTheme] = [
    .init(name: "Indigo",   baseTop: 0x1A1A2E, baseBottom: 0x16213E, glow: 0x00F5D4),
    .init(name: "Midnight", baseTop: 0x0D1B2A, baseBottom: 0x1B263B, glow: 0xE0AAFF),
    .init(name: "Forest",   baseTop: 0x1B2A1B, baseBottom: 0x14241C, glow: 0x95D5B2),
    .init(name: "Slate",    baseTop: 0x2B2D42, baseBottom: 0x1D1E2C, glow: 0x8ECAE6),
    .init(name: "Crimson",  baseTop: 0x2A0E0E, baseBottom: 0x1A0606, glow: 0xFF6B6B),
]

/// Clock face size presets.
enum ClockSize: Int, CaseIterable {
    case small, medium, large
    var scale: Double { [Self.small: 0.8, .medium: 1.0, .large: 1.3][self]! }
    var label: String { [Self.small: "Small", .medium: "Medium", .large: "Large"][self]! }
}

/// How strong the change flashes are.
enum FlashIntensity: Int, CaseIterable {
    case subtle, normal, strong
    var scale: Double { [Self.subtle: 0.55, .normal: 0.85, .strong: 1.0][self]! }
    var label: String { [Self.subtle: "Subtle", .normal: "Normal", .strong: "Strong"][self]! }
}

/// Which numerals the face shows. Time Timer research: pure visual depletion
/// (no numbers) is easier to *feel* for time-blind users.
enum NumberVisibility: Int, CaseIterable {
    case full, hideSeconds, hideAll
    var label: String {
        [Self.full: "Full", .hideSeconds: "Hide Seconds", .hideAll: "Hide All"][self]!
    }
}

/// How remaining time is drawn — a perimeter ring or a Time Timer-style disk.
enum DepletionStyle: Int, CaseIterable {
    case ring, disk
    var label: String { [Self.ring: "Ring", .disk: "Disk"][self]! }
}

/// Holds the current time, user preferences (persisted), and the session timer.
final class ClockModel: ObservableObject {
    @Published var date = Date()

    // MARK: Preferences (persisted in UserDefaults)
    @Published var muted: Bool                { didSet { save() } }
    @Published var nudgeInterval: Int         { didSet { save() } }
    @Published var use24Hour: Bool            { didSet { save() } }
    @Published var size: ClockSize            { didSet { save() } }
    @Published var intensity: FlashIntensity  { didSet { save() } }
    @Published var autoMuteInCalls: Bool      { didSet { save() } }
    @Published var showElapsed: Bool          { didSet { save() } }
    @Published var themeIndex: Int            { didSet { save() } }
    @Published var showDepletion: Bool        { didSet { save() } }
    @Published var numberVisibilityRaw: Int   { didSet { save() } }
    @Published var depletionStyleRaw: Int     { didSet { save() } }
    @Published var calmMode: Bool             { didSet { save() } }

    var theme: ClockTheme { clockThemes[min(max(0, themeIndex), clockThemes.count - 1)] }
    var numberVisibility: NumberVisibility { NumberVisibility(rawValue: numberVisibilityRaw) ?? .full }
    var depletionStyle: DepletionStyle { DepletionStyle(rawValue: depletionStyleRaw) ?? .ring }

    // MARK: Animation triggers (view watches these)
    @Published var minuteTick = 0
    @Published var hourTick = 0
    @Published var nudgeTick = 0

    // MARK: Session ("time sitting")
    @Published var sessionStart = Date()
    @Published var elapsedText = "0m"

    // MARK: Focus block (Pomodoro-style countdown)
    @Published var focusEnd: Date?
    @Published var focusRemaining = ""
    @Published var focusEndedTick = 0
    var focusActive: Bool { focusEnd != nil }
    private(set) var focusTotalSeconds: Double = 0

    // MARK: Call state (for auto-mute)
    @Published var callActive = false

    /// True when sound should be silenced — manual mute, or auto-mute in a call.
    var soundSuppressed: Bool { muted || (autoMuteInCalls && callActive) }

    private let defaults = UserDefaults.standard
    private var loaded = false

    init() {
        let d = UserDefaults.standard
        muted = d.bool(forKey: "muted")
        nudgeInterval = d.integer(forKey: "nudgeInterval")
        use24Hour = d.bool(forKey: "use24Hour")
        size = ClockSize(rawValue: d.object(forKey: "size") as? Int ?? ClockSize.medium.rawValue) ?? .medium
        intensity = FlashIntensity(rawValue: d.object(forKey: "intensity") as? Int ?? FlashIntensity.normal.rawValue) ?? .normal
        autoMuteInCalls = d.bool(forKey: "autoMuteInCalls")
        showElapsed = d.bool(forKey: "showElapsed")
        themeIndex = d.integer(forKey: "themeIndex")
        showDepletion = d.bool(forKey: "showDepletion")
        numberVisibilityRaw = d.integer(forKey: "numberVisibility")
        depletionStyleRaw = d.integer(forKey: "depletionStyle")
        calmMode = d.bool(forKey: "calmMode")
        loaded = true
        updateElapsed()
    }

    private func save() {
        guard loaded else { return }
        defaults.set(muted, forKey: "muted")
        defaults.set(nudgeInterval, forKey: "nudgeInterval")
        defaults.set(use24Hour, forKey: "use24Hour")
        defaults.set(size.rawValue, forKey: "size")
        defaults.set(intensity.rawValue, forKey: "intensity")
        defaults.set(autoMuteInCalls, forKey: "autoMuteInCalls")
        defaults.set(showElapsed, forKey: "showElapsed")
        defaults.set(themeIndex, forKey: "themeIndex")
        defaults.set(showDepletion, forKey: "showDepletion")
        defaults.set(numberVisibilityRaw, forKey: "numberVisibility")
        defaults.set(depletionStyleRaw, forKey: "depletionStyle")
        defaults.set(calmMode, forKey: "calmMode")
    }

    func resetSession() {
        sessionStart = Date()
        updateElapsed()
    }

    /// Refresh the "time sitting" string (e.g. "1h 23m").
    func updateElapsed() {
        let total = max(0, Int(Date().timeIntervalSince(sessionStart)))
        let h = total / 3600, m = (total % 3600) / 60
        elapsedText = h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    func startFocus(minutes: Int) {
        focusTotalSeconds = Double(minutes * 60)
        focusEnd = Date().addingTimeInterval(focusTotalSeconds)
        _ = updateFocus()
    }

    func stopFocus() {
        focusEnd = nil
        focusRemaining = ""
        focusTotalSeconds = 0
    }

    /// Refresh the focus countdown string. Returns true if it just hit zero.
    @discardableResult
    func updateFocus() -> Bool {
        guard let end = focusEnd else { return false }
        let remaining = end.timeIntervalSinceNow
        if remaining <= 0 {
            focusEnd = nil
            focusRemaining = ""
            return true
        }
        let s = Int(remaining.rounded(.up))
        focusRemaining = String(format: "%d:%02d", s / 60, s % 60)
        return false
    }
}
