import AppKit

// Entry point. SwiftPM executable -> create NSApplication manually so we
// control the activation policy and window level (needed for always-on-top).
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// .accessory = no Dock icon, no app menu bar. Behaves like a desktop widget.
// Quit is offered through the status-bar item created in the delegate.
app.setActivationPolicy(.accessory)
app.run()
