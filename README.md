# Floating Clock

A always-on-top macOS floating clock — like Picture-in-Picture. Shows
`H:MM:SS` with an `AM`/`PM` badge, rides on top of every window and every
Space, and **ticks every second** with an alternating tick/tock sound.

## Run it

Quick (dev, stays tied to the terminal):

```bash
swift run
```

As a real double-clickable app (recommended):

```bash
./make-app.sh
open FloatingClock.app      # or drag it to /Applications
```

Quit / mute from the **clock icon in the menu bar**.

## Controls

| Action            | How                                        |
|-------------------|--------------------------------------------|
| Move the clock    | Drag it anywhere on screen                 |
| Mute / unmute     | Menu-bar clock icon → *Mute Ticking* (⌘M)  |
| Quit              | Menu-bar clock icon → *Quit* (⌘Q)          |

## The ticking sound

A mechanical clock makes **two** different sounds, not one — the escapement
*engages* ("tick") and *releases* ("tock"), alternating every second. That is
why we say "tick-tock". This app reproduces that:

- **Odd seconds** → `tick`: a short, higher click (~1000 Hz).
- **Even seconds** → `tock`: a slightly longer, lower click (~750 Hz).

So the sound genuinely **changes each second**. Both clicks are *synthesized
in code* at launch (a sine burst shaped by an exponential decay envelope) — no
audio files are bundled. See `Sources/FloatingClock/TickPlayer.swift`.

The tick is aligned to the real wall-clock second boundary, so it fires the
instant the displayed second changes.

## How "always-on-top / PiP" works

The window is a borderless, non-activating `NSPanel` with:

- `level = .floating` — stays above ordinary windows.
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`
  — follows you across Spaces and over full-screen apps.

## Project layout

```
Sources/FloatingClock/
  main.swift        Entry point, NSApplication + .accessory policy
  AppDelegate.swift Floating panel, menu-bar item, per-second tick loop
  ClockView.swift   SwiftUI clock face (time + AM/PM, translucent card)
  ClockModel.swift  Observable time + mute state
  TickPlayer.swift  Synthesized tick/tock audio (AVAudioEngine)
```
