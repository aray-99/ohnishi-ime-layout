# CLAUDE.md

## 1. Mission

Build and maintain a small, dependable AutoHotkey v2 application that optimizes
Japanese romaji typing on Windows with the Ohnishi layout.

The product is **not** intended to enforce the Ohnishi layout everywhere.

The core behavior is:

- Use the Ohnishi layout only while a Japanese IME is in a Japanese
  kana/katakana composition mode.
- Use QWERTY while the Japanese IME is in an alphanumeric mode.
- Keep Ctrl, Alt, and Windows-key shortcuts QWERTY regardless of IME state.
- Do not implement chorded typing, timing-based character decisions, or
  tap/hold behavior for character keys.
- Prefer predictable behavior, low latency, and easy recovery over features.

Read all files under `docs/` before changing source code.

## 2. Required model and working style

Use the most capable generally available Claude Code model for architecture,
implementation, debugging, and final review. The repository owner currently
recommends the `opus` model alias.

Work autonomously until the current issue's acceptance criteria are satisfied
or an external blocker makes progress impossible.

Do not ask the user to make routine implementation choices. Make the smallest
reasonable decision consistent with this document and record material design
decisions in `docs/decisions.md`.

## 3. Source-of-truth priority

When instructions conflict, use this priority:

1. The currently assigned GitHub Issue and its acceptance criteria
2. This `CLAUDE.md`
3. `docs/requirements.md`
4. `docs/basic-design.md`
5. `docs/decisions.md`
6. README and other documentation
7. Existing implementation details

Do not silently contradict a higher-priority source.

## 4. Mandatory GitHub Issue workflow

All implementation, behavior changes, fixes, and material documentation changes
must be associated with a GitHub Issue.

Before implementation begins:

1. Ensure the initial documentation is pushed to GitHub.
2. Create the issues listed in `docs/issue-plan.md`.
3. Add any missing issue discovered during technical investigation.
4. Work on one issue at a time unless two issues are inseparable.
5. Create a dedicated `feature/issue-<number>-<short-name>` branch off
   `develop` (git-flow; see `CONTRIBUTING.md` and ADR-012).
6. Keep commits focused on the issue and use Conventional Commit subjects.
7. Include `Closes #<number>` in the final commit or pull-request body.
8. Do not close an issue until its acceptance criteria are met.
9. Push the branch and open a pull request into `develop` when remote access
   and `gh` are available. Merge with `--no-ff`.
10. Merge only when checks pass. If automatic merging is unavailable, leave a
    clear merge-ready pull request.
11. Release work uses a `release/<version>` branch off `develop`, merged into
    `main` and tagged, then merged back into `develop`. `main` is release-only.

Never create empty “process” commits only to close an issue.

If the environment cannot access GitHub, perform the local work, prepare the
exact `gh` commands or pull-request text, and report the blocker. Do not pretend
that remote operations succeeded.

## 5. Initial repository publication

For the first Claude Code session, follow this order:

1. Inspect the repository and read all documentation.
2. Verify that Git is initialized and the Initial Commit exists.
3. If no GitHub remote exists, ask only for the unavoidable repository
   destination or authentication action.
4. Push the Initial Commit.
5. Run `scripts/create-issues.ps1` or create equivalent issues with `gh`.
6. Begin with the technical-spike issue.
7. Do not add production behavior to the Initial Commit retroactively.

## 6. Scope and release stages

### Release 1: JIS Core

Release 1 is the first completion target.

It includes:

- AutoHotkey v2.0 stable
- resident script behavior
- Japanese IME mode detection
- Ohnishi layout only in Japanese romaji composition modes
- QWERTY in Japanese IME alphanumeric modes
- QWERTY for Ctrl/Alt/Win shortcuts
- Shift-compatible Ohnishi input
- no character-key timing or chord interpretation
- safe enable/disable, reload, status, and exit commands
- application exclusions
- manual verification checklist
- installation and recovery documentation

### Release 2: US compatibility layer

Do not block Release 1 on this work.

It includes:

- manual `JIS` / `US_COMPAT` profile selection
- US physical-key symbol correction while avoiding frequent Win+Space switching
- priority support for LaTeX symbols, especially backslash
- verified interaction with shortcuts and Japanese IME modes

Automatic per-device keyboard detection is a future option, not an initial
requirement.

## 7. Core behavioral rules

Define the Ohnishi character hotkeys so that they are active only when all
conditions are true:

- application-level layout switch is enabled
- the foreground application is not excluded
- the Japanese IME is in an applicable kana/katakana composition mode
- Ctrl is not pressed
- Alt is not pressed
- either Windows key is not pressed

Shift alone does not disable the Ohnishi layout.

If IME state cannot be determined safely, fall back to QWERTY.

Generated key events must not be remapped again.

Do not log typed keys, characters, clipboard contents, document contents, or
password-related data.

## 8. Ohnishi layout

Use this physical-to-logical mapping for Japanese composition:

```text
Physical: Q W E R T Y U I O P
Logical:  Q L U , . F W R Y P

Physical: A S D F G H J K L ;
Logical:  E I A O - K T N S H

Physical: Z X C V B N M , . /
Logical:  Z X C V ; G D M J B
```

Mappings whose source and destination are identical may be omitted from code,
but the complete mapping must remain documented and tested.

## 9. Shortcut policy

Ctrl, Alt, and Windows-key combinations are QWERTY-first.

Do not enumerate only known shortcuts. Prefer a context rule that bypasses the
Ohnishi character remapping whenever Ctrl, Alt, or Win is down.

This includes punctuation shortcuts such as zoom in/out. On the owner's JIS
environment, `Ctrl + +` and `Ctrl + -` must work during Japanese input without
requiring an additional Shift press.

Test physical operations on the actual JIS and US profiles rather than assuming
that the printed symbol corresponds to the same virtual key.

## 10. Fast-typing requirements

Character keys must be independent.

Do not:

- define character-key chords
- wait for another character key
- use timing windows to decide a character
- wait for key-up before committing normal character input
- assign tap/hold semantics to character keys
- delay ordinary character output with timers or sleeps

Overlapping key-down periods must remain ordinary sequential typing. Preserve
normal key repeat where practical.

Acceptance is pragmatic: no reproducible character loss, order reversal, stuck
modifier, or special-action misfire during normal fast typing.

## 11. PowerToys and personal remaps

The owner's current CapsLock / 半角・全角 swap remains in PowerToys for Release 1.

The public core must not depend on this swap.

Do not remap the same physical key in both PowerToys and AutoHotkey.

If migration becomes necessary because of conflict or maintenance difficulty,
put it in a separately optional personal module. Never enable it by default in
the public core.

Local personal settings must not be committed. Use example files and ignored
`.local.ahk` files.

## 12. Implementation standards

- Use AutoHotkey v2 syntax only.
- Add `#Requires AutoHotkey v2.0`.
- Prefer a small number of understandable files over speculative modularity.
- Keep platform/IME API calls behind narrow functions.
- Keep policy decisions separate from Windows API plumbing.
- Avoid external dependencies unless the issue explains why they are needed.
- Treat failure to detect context as a reason not to remap.
- Keep comments focused on intent and non-obvious constraints.
- Do not add telemetry or network access.

## 13. Verification

Because this is an input-remapping application, automated tests cannot replace
manual Windows verification.

For every behavior issue:

1. Run any available static or syntax checks.
2. Update `docs/manual-test-checklist.md`.
3. Record what was actually tested and what remains unverified.
4. Never claim hardware or IME verification that was not performed.

Before Release 1, manually verify at minimum:

- hiragana mode activates Ohnishi
- katakana mode follows the agreed behavior
- half-width and full-width alphanumeric modes remain QWERTY
- Ctrl/Alt/Win shortcuts remain QWERTY
- `Ctrl + +` and `Ctrl + -` work in the owner's JIS environment
- Shift uppercase and shifted punctuation
- fast overlapping typing
- repeated keys and key repeat
- enable/disable, reload, status, and emergency exit
- script exit restores ordinary QWERTY behavior

## 14. Documentation and commits

Update documentation in the same issue that changes behavior.

Use Conventional Commit-style subjects where practical:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `test: ...`
- `refactor: ...`
- `chore: ...`

The final issue-closing commit or PR body must contain `Closes #N`.

Do not rewrite published history unless the repository owner explicitly asks.

## 15. Completion report

At the end of each issue, report:

- issue number and result
- files changed
- checks and manual tests run
- unverified items
- design decisions added
- commit and pull-request identifiers
- remaining blockers or next issue

Be concise and factual.
