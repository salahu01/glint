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
}
