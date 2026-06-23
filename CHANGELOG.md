# Changelog

All notable changes to **Glint** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-06-23

### Added
- **Focus blocks (Pomodoro)** — *Focus Block* menu starts a 25 or 50 min
  session with a live countdown on the clock face and a blink + chime when it
  ends.
- **"Time sitting" readout** — optional line showing how long the current
  session has run, with *Reset Session Timer*.
- **Auto-mute in calls** — silences ticking while the mic is in use (reads
  device state only; no mic permission required).
- **Preferences** — 24-hour clock, three clock sizes, and three flash
  intensities, all persisted across launches.
- **Launch at Login** toggle (via `SMAppService`).

## [1.1.0] - 2026-06-23

### Added
- **Interval nudges** — choose 15 / 25 / 30 / 60 minutes from the menu-bar
  *Nudge Me Every* submenu. Glint blinks (violet→cyan) and triple-chimes at
  each wall-clock mark as a deliberate "time check / take a break" cue.

## [1.0.0] - 2026-06-23

First public release. 🎉

### Added
- Always-on-top floating clock panel — visible across all Spaces and over
  full-screen apps (Picture-in-Picture style).
- Large glanceable face: `H:MM` on top, `SS` + `AM`/`PM` below, monospaced.
- Synthesized **tick / tock** every second (alternating pitch), plus **chimes**
  on the minute (single) and hour (double) — all generated in code, no audio
  assets.
- Attention states so time changes are impossible to miss:
  - amber → red buildup wash over the final 10 seconds of a minute,
  - teal burst flash on minute roll-over,
  - bigger orange → magenta burst flash + double chime on the hour.
- High-contrast indigo palette with a cyan glow that reddens as a change nears.
- Drag-to-move anywhere on screen.
- Menu-bar item to mute ticking (⌘M) and quit (⌘Q).
- Launcher / app icon.
- `make-app.sh` to build and ad-hoc sign a double-clickable `Glint.app`.

[Unreleased]: https://github.com/salahu01/glint/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/salahu01/glint/releases/tag/v1.2.0
[1.1.0]: https://github.com/salahu01/glint/releases/tag/v1.1.0
[1.0.0]: https://github.com/salahu01/glint/releases/tag/v1.0.0
