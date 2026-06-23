import AppKit
import SwiftUI
import Combine
import ServiceManagement

/// Owns the floating panel, the status-bar menu, and the per-second tick loop.
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let model = ClockModel()
    private let ticker = TickPlayer()
    private var panel: NSPanel!
    private var statusItem: NSStatusItem!
    private var cancellables = Set<AnyCancellable>()
    private var lastMinute = -1
    private var lastHour = -1

    // Menu items that need live state refresh.
    private var muteItem: NSMenuItem!
    private var elapsedItem: NSMenuItem!
    private var autoMuteItem: NSMenuItem!
    private var loginItem: NSMenuItem!
    private var show24Item: NSMenuItem!
    private var showElapsedItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildPanel()
        buildStatusItem()
        observeLayoutChanges()
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
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isMovableByWindowBackground = true
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

    /// When a preference changes the face's footprint, resize the panel while
    /// keeping its top-right corner pinned.
    private func observeLayoutChanges() {
        let focusToggle = model.$focusEnd.map { $0 != nil }.removeDuplicates().map { _ in () }
        model.$size.map { _ in () }
            .merge(with: model.$use24Hour.map { _ in () },
                   model.$showElapsed.map { _ in () },
                   focusToggle)
            .sink { [weak self] in
                DispatchQueue.main.async { self?.relayoutPanel() }
            }
            .store(in: &cancellables)
    }

    private func relayoutPanel() {
        guard let panel, let hosting = panel.contentView else { return }
        hosting.layoutSubtreeIfNeeded()
        let newSize = hosting.fittingSize
        let old = panel.frame
        let origin = NSPoint(x: old.maxX - newSize.width, y: old.maxY - newSize.height)
        panel.setFrame(NSRect(origin: origin, size: newSize), display: true, animate: true)
    }

    // MARK: - Status-bar menu

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Glint")

        let menu = NSMenu()
        menu.delegate = self

        elapsedItem = NSMenuItem(title: "Sitting for 0m", action: nil, keyEquivalent: "")
        elapsedItem.isEnabled = false
        menu.addItem(elapsedItem)
        let reset = item("Reset Session Timer", #selector(resetSession))
        menu.addItem(reset)
        menu.addItem(.separator())

        // Nudge interval submenu.
        let nudge = NSMenuItem(title: "Nudge Me Every", action: nil, keyEquivalent: "")
        let nudgeMenu = NSMenu()
        for minutes in [0, 15, 25, 30, 60] {
            let it = NSMenuItem(title: minutes == 0 ? "Off" : "\(minutes) min",
                                action: #selector(setNudgeInterval(_:)), keyEquivalent: "")
            it.target = self
            it.tag = minutes
            it.state = minutes == model.nudgeInterval ? .on : .off
            nudgeMenu.addItem(it)
        }
        nudge.submenu = nudgeMenu
        menu.addItem(nudge)

        // Focus block submenu (Pomodoro-style countdown).
        let focusMenu = NSMenu()
        let focusOff = NSMenuItem(title: "Off", action: #selector(stopFocusAction), keyEquivalent: "")
        focusOff.target = self
        focusOff.tag = 0
        focusMenu.addItem(focusOff)
        for minutes in [25, 50] {
            let it = NSMenuItem(title: "Start \(minutes) min", action: #selector(startFocus(_:)), keyEquivalent: "")
            it.target = self
            it.tag = minutes
            focusMenu.addItem(it)
        }
        let focusItem = NSMenuItem(title: "Focus Block", action: nil, keyEquivalent: "")
        focusItem.submenu = focusMenu
        menu.addItem(focusItem)

        // Size submenu.
        let sizeMenu = NSMenu()
        for s in ClockSize.allCases {
            let it = NSMenuItem(title: s.label, action: #selector(setSize(_:)), keyEquivalent: "")
            it.target = self
            it.tag = s.rawValue
            it.state = s == model.size ? .on : .off
            sizeMenu.addItem(it)
        }
        let sizeItem = NSMenuItem(title: "Clock Size", action: nil, keyEquivalent: "")
        sizeItem.submenu = sizeMenu
        menu.addItem(sizeItem)

        // Flash intensity submenu.
        let intensityMenu = NSMenu()
        for fi in FlashIntensity.allCases {
            let it = NSMenuItem(title: fi.label, action: #selector(setIntensity(_:)), keyEquivalent: "")
            it.target = self
            it.tag = fi.rawValue
            it.state = fi == model.intensity ? .on : .off
            intensityMenu.addItem(it)
        }
        let intensityItem = NSMenuItem(title: "Flash Intensity", action: nil, keyEquivalent: "")
        intensityItem.submenu = intensityMenu
        menu.addItem(intensityItem)

        // Color theme submenu.
        let themeMenu = NSMenu()
        for (i, t) in clockThemes.enumerated() {
            let it = NSMenuItem(title: t.name, action: #selector(setTheme(_:)), keyEquivalent: "")
            it.target = self
            it.tag = i
            it.state = i == model.themeIndex ? .on : .off
            themeMenu.addItem(it)
        }
        let themeItem = NSMenuItem(title: "Color Theme", action: nil, keyEquivalent: "")
        themeItem.submenu = themeMenu
        menu.addItem(themeItem)
        menu.addItem(.separator())

        show24Item = item("24-Hour Clock", #selector(toggle24Hour))
        menu.addItem(show24Item)
        showElapsedItem = item("Show Time Sitting", #selector(toggleShowElapsed))
        menu.addItem(showElapsedItem)
        autoMuteItem = item("Auto-Mute in Calls", #selector(toggleAutoMute))
        menu.addItem(autoMuteItem)
        muteItem = item("Mute Ticking", #selector(toggleMute), key: "m")
        menu.addItem(muteItem)
        menu.addItem(.separator())

        loginItem = item("Launch at Login", #selector(toggleLogin))
        menu.addItem(loginItem)
        let quit = item("Quit Glint", #selector(quitApp), key: "q")
        menu.addItem(quit)

        statusItem.menu = menu
    }

    private func item(_ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let it = NSMenuItem(title: title, action: action, keyEquivalent: key)
        it.target = self
        return it
    }

    /// Refresh dynamic state right before the menu opens.
    func menuNeedsUpdate(_ menu: NSMenu) {
        model.updateElapsed()
        elapsedItem.title = "Sitting for \(model.elapsedText)"
        muteItem.title = model.muted ? "Unmute Ticking" : "Mute Ticking"
        autoMuteItem.state = model.autoMuteInCalls ? .on : .off
        show24Item.state = model.use24Hour ? .on : .off
        showElapsedItem.state = model.showElapsed ? .on : .off
        loginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
    }

    // MARK: - Menu actions

    @objc private func setNudgeInterval(_ sender: NSMenuItem) {
        model.nudgeInterval = sender.tag
        sender.menu?.items.forEach { $0.state = ($0.tag == sender.tag) ? .on : .off }
    }

    @objc private func setSize(_ sender: NSMenuItem) {
        model.size = ClockSize(rawValue: sender.tag) ?? .medium
        sender.menu?.items.forEach { $0.state = ($0.tag == sender.tag) ? .on : .off }
    }

    @objc private func setIntensity(_ sender: NSMenuItem) {
        model.intensity = FlashIntensity(rawValue: sender.tag) ?? .normal
        sender.menu?.items.forEach { $0.state = ($0.tag == sender.tag) ? .on : .off }
    }

    @objc private func setTheme(_ sender: NSMenuItem) {
        model.themeIndex = sender.tag
        sender.menu?.items.forEach { $0.state = ($0.tag == sender.tag) ? .on : .off }
    }

    @objc private func startFocus(_ sender: NSMenuItem) { model.startFocus(minutes: sender.tag) }
    @objc private func stopFocusAction() { model.stopFocus() }

    @objc private func toggle24Hour() { model.use24Hour.toggle() }
    @objc private func toggleShowElapsed() { model.showElapsed.toggle() }
    @objc private func toggleAutoMute() { model.autoMuteInCalls.toggle() }
    @objc private func toggleMute() { model.muted.toggle() }
    @objc private func resetSession() { model.resetSession() }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Glint: launch-at-login toggle failed: \(error)")
        }
    }

    @objc private func quitApp() { NSApp.terminate(nil) }

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
        model.updateElapsed()
        if model.autoMuteInCalls { model.callActive = MicMonitor.isInputActive() }

        // Focus countdown: fire a finish cue the moment it hits zero.
        if model.updateFocus() {
            model.focusEndedTick += 1
            if !model.soundSuppressed { ticker.playChime(times: 4) }
        }

        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let hour = c.hour ?? 0, minute = c.minute ?? 0, second = c.second ?? 0

        let hourRolled = lastMinute != -1 && hour != lastHour
        let minuteRolled = lastMinute != -1 && minute != lastMinute
        lastHour = hour
        lastMinute = minute

        let isNudge = minuteRolled
            && model.nudgeInterval > 0
            && minute % model.nudgeInterval == 0

        let silent = model.soundSuppressed
        if isNudge {
            model.nudgeTick += 1
            if !silent { ticker.playChime(times: 3) }
        } else if hourRolled {
            model.hourTick += 1
            if !silent { ticker.playChime(times: 2) }
        } else if minuteRolled {
            model.minuteTick += 1
            if !silent { ticker.playChime(times: 1) }
        } else if !silent {
            ticker.play(forSecond: second)
        }
    }
}
