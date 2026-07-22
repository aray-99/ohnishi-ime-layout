# Changelog

All notable changes will be documented in this file.

## Unreleased

### Added

- IME context detection module `src/ime.ahk` (WM_IME_CONTROL via
  SendMessageTimeout; NATIVE-bit rule; QWERTY fallback on failure).
- Release 1 JIS Ohnishi layout core (`OhnishiLayout.ahk`, `src/ohnishi-map.ahk`):
  applies the mapping only in a Japanese kana/katakana composition mode with no
  Ctrl/Alt/Win held; Shift-compatible; no chords/timing/tap-hold/key-up wait;
  generated keys are not re-remapped; `#SingleInstance Force`.
- Decision policy `src/context.ahk` (`Layout` class) with enable/disable and
  application exclusions.
- Resident operation: tray menu and management hotkeys (enable/disable, status,
  reload, emergency exit), optional auto-loaded `personal.local.ahk`.
- Spike harness `spike/ime-spike.ahk` (observer, 3-key test, key identifier).
- Static-check script `scripts/check-syntax.ps1`.
- Docs: `docs/spike-ime.md`, `docs/operations.md`, `CONTRIBUTING.md`; git-flow
  adoption; ADR-009…012.

### From the Initial Commit

- Requirements, basic design, Claude Code instructions, issue plan, manual
  verification checklist, issue bootstrap script.

## Release 1 tag proposal

After the owner completes the manual hardware verification (issue #4) with no
blocking defects, cut `release/1.0.0` from `develop`, set the version, merge into
`main`, and tag **v1.0.0** ("Release 1: JIS Core"). See `CONTRIBUTING.md`.
