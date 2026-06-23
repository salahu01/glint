import Foundation
import Combine

/// Holds the current time plus user-facing toggles, published to the SwiftUI view.
final class ClockModel: ObservableObject {
    @Published var date = Date()
    @Published var muted = false

    /// Increments whenever the minute / hour rolls over. The view watches these
    /// to fire its attention-grabbing flash animations.
    @Published var minuteTick = 0
    @Published var hourTick = 0

    /// Interval nudge: a deliberate "time check" every N minutes (0 = off).
    /// Fires at wall-clock multiples (e.g. 15 → :00, :15, :30, :45).
    @Published var nudgeInterval = 0
    /// Increments each time a nudge fires; the view blinks on it.
    @Published var nudgeTick = 0
}
