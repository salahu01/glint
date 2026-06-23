# Changelog

All notable changes to **Glint** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/salahu01/floating-clock/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/salahu01/floating-clock/releases/tag/v1.0.0
