import AppKit
import SwiftUI

/// Owns the floating panel, the status-bar menu, and the per-second tick loop.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = ClockModel()
    private let ticker = TickPlayer()
    private var panel: NSPanel!
    private var statusItem: NSStatusItem!
    private var muteMenuItem: NSMenuItem!
    private var lastMinute = -1
    private var lastHour = -1

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildPanel()
        buildStatusItem()
        scheduleNextTick()
    }

    // MARK: - Floating panel (always-on-top, all Spaces, like PiP)

    private func buildPanel() {
        let hosting = NSHostingView(rootView: ClockView().environmentObject(model))
        hosting.layoutSubtreeIfNeeded()
        let size = hosting.fittingSize

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        // .floating keeps it above ordinary windows; the collection behavior
        // makes it ride along to every Space and over full-screen apps.
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isMovableByWindowBackground = true      // drag the clock anywhere
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.contentView = hosting

        if let screen = NSScreen.main {
            let margin: CGFloat = 24
            let frame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(
                x: frame.maxX - size.width - margin,
                y: frame.maxY - size.height - margin
            ))
        }
        panel.orderFrontRegardless()
        self.panel = panel
    }

    // MARK: - Status-bar menu (mute / quit)

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Floating Clock")

        let menu = NSMenu()
        muteMenuItem = NSMenuItem(title: "Mute Ticking", action: #selector(toggleMute), keyEquivalent: "m")
        muteMenuItem.target = self
        menu.addItem(muteMenuItem)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Floating Clock", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
    }

    @objc private func toggleMute() {
        model.muted.toggle()
        muteMenuItem.title = model.muted ? "Unmute Ticking" : "Mute Ticking"
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Tick loop, aligned to real second boundaries

    private func scheduleNextTick() {
        let now = Date().timeIntervalSinceReferenceDate
        let untilNextSecond = ceil(now) - now
        let delay = untilNextSecond <= 0.0005 ? 1.0 : untilNextSecond
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.tick()
            self?.scheduleNextTick()
        }
    }

    private func tick() {
        let date = Date()
        model.date = date

        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let hour = c.hour ?? 0, minute = c.minute ?? 0, second = c.second ?? 0

        // Detect roll-overs (skip the very first tick after launch).
        let hourRolled = lastMinute != -1 && hour != lastHour
        let minuteRolled = lastMinute != -1 && minute != lastMinute
        lastHour = hour
        lastMinute = minute

        if hourRolled {
            model.hourTick += 1
            if !model.muted { ticker.playChime(double: true) }
        } else if minuteRolled {
            model.minuteTick += 1
            if !model.muted { ticker.playChime(double: false) }
        } else if !model.muted {
            ticker.play(forSecond: second)   // ordinary tick/tock
        }
    }
}
