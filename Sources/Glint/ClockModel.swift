import Foundation
import Combine

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
        focusEnd = Date().addingTimeInterval(Double(minutes * 60))
        _ = updateFocus()
    }

    func stopFocus() {
        focusEnd = nil
        focusRemaining = ""
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
