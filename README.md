<div align="center">

# ✨ Glint

### A glanceable, always-on-top clock that *glints* when time changes.

Glint floats above every window and every Space — like Picture-in-Picture for
your clock. It ticks like a real mechanical clock and **flashes in bold color
the moment a minute or hour changes**, so you actually notice time passing
instead of losing track of it.

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-1A1A2E?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-6-FB5607?style=flat-square)
![Release](https://img.shields.io/github/v/release/salahu01/floating-clock?style=flat-square&color=00F5D4)
![License](https://img.shields.io/badge/license-MIT-2EC4B6?style=flat-square)

</div>

---

## Why Glint?

A normal clock is easy to ignore — you glance, you forget. Glint is built to
**pull your eye at the right moment**:

- A warm **amber → red wash** builds up over the final 10 seconds of a minute
  (peripheral-vision warning that a change is coming).
- A **teal burst** flashes the whole card when the minute rolls over.
- A bigger **orange → magenta burst** + a **double chime** marks every hour.

You feel time moving, even when you're not staring at it.

## Features

- 🪟 **Always on top, every Space** — borderless floating panel, rides over
  full-screen apps too (PiP-style).
- 🕐 **Big, glanceable face** — `H:MM` large up top, `SS` + `AM`/`PM` below,
  monospaced so it never jitters.
- 🔔 **Real tick-tock** — alternating tick (high) and tock (low) every second,
  plus chimes on the minute and hour. All sound is *synthesized in code* — no
  audio files bundled.
- 🎨 **Attention palette** — high-contrast indigo base with cyan glow, escalating
  to red as a change approaches and a bold flash at the change.
- 🖐️ **Drag anywhere** — grab it and move it to any corner.
- 🔇 **One-click mute** & quit from the menu-bar item.
- 🪶 **Tiny & native** — pure Swift / AppKit / SwiftUI, no dependencies, no Dock
  clutter (`LSUIElement` agent app).

## The change states

| State | When | Card | Sound |
|-------|------|------|-------|
| **Calm** | `:00`–`:49` | Deep indigo, white digits, cyan glow | tick / tock |
| **Buildup** | `:50`–`:59` | Amber→red wash fades in, glow reddens, border brightens | tick / tock |
| **Minute** | minute rolls over | Teal→cyan **burst flash** | single chime |
| **Hour** | hour rolls over | Orange→magenta **burst flash** (bigger, longer) | double chime |

## Install

### Download (recommended)

1. Grab `Glint.app.zip` from the [latest release](https://github.com/salahu01/floating-clock/releases/latest).
2. Unzip, drag **Glint.app** to `/Applications`.
3. First launch: right-click → **Open** (it's ad-hoc signed, so Gatekeeper
   asks once).

### Build from source

```bash
git clone git@github.com:salahu01/floating-clock.git
cd floating-clock

# Run straight away (dev):
swift run

# …or build a double-clickable app bundle:
./make-app.sh
open Glint.app          # or drag it to /Applications
```

Requires macOS 13+ and a Swift 5.9+ toolchain (Xcode 15+).

## Usage

Glint launches into the **top-right** corner. Control it from the **clock icon
in the menu bar**:

| Action | How |
|--------|-----|
| Move the clock | Drag it anywhere on screen |
| Mute / unmute ticking | Menu-bar clock icon → *Mute Ticking* (⌘M) |
| Quit | Menu-bar clock icon → *Quit Glint* (⌘Q) |

Want it on every login? **System Settings → General → Login Items → +** → Glint.

## How it works

- **Always-on-top:** a borderless, non-activating `NSPanel` with
  `level = .floating` and
  `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`.
- **Tick accuracy:** the loop reschedules itself to the next whole-second
  boundary each tick, so it fires exactly when the displayed second flips — no
  drift.
- **Sound:** `AVAudioEngine` plays short PCM buffers synthesized at launch — a
  sine burst shaped by an exponential decay for the clicks, and a fundamental +
  harmonics ring for the chimes.
- **Flashes:** SwiftUI color overlays animated on `minuteTick` / `hourTick`
  counters — no window resizing, so nothing clips.

## Project layout

```
Sources/Glint/
  main.swift         Entry point — NSApplication, .accessory policy
  AppDelegate.swift  Floating panel, menu-bar item, per-second tick loop
  ClockView.swift    SwiftUI face: palette, states, flash animations
  ClockModel.swift   Observable time + mute + roll-over tick counters
  TickPlayer.swift   Synthesized tick / tock / chime audio
make-app.sh          Bundles & ad-hoc signs Glint.app
```

## Roadmap

- [ ] App icon
- [ ] Preferences: colors, sizes, 24-hour mode, flash intensity
- [ ] Launch-at-login toggle in the menu
- [ ] Notarized, signed release build

## License

[MIT](LICENSE) © salahu01
