$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is required."
}

gh auth status | Out-Host

$issues = @(
    @{
        Title = "spike: verify Windows IME modes and AutoHotkey key delivery"
        Labels = @("type:spike", "area:ime", "release:1")
        Body = @'
## Purpose

Verify Windows Japanese IME mode detection and select a safe AutoHotkey v2 key
delivery method before production implementation.

## Acceptance criteria

- [ ] Record observations for IME OFF, hiragana, katakana, half-width
      alphanumeric, and full-width alphanumeric modes
- [ ] Define which observed modes activate the Ohnishi layout
- [ ] Implement a 1-3 key experimental remap
- [ ] Verify or provide an exact manual procedure for Ctrl bypass
- [ ] Verify or provide an exact manual procedure for Shift, key repeat, and
      overlapping key presses
- [ ] Compare candidate remap/send approaches
- [ ] Record the adopted approach and rejected approaches in
      `docs/decisions.md`
- [ ] Clearly mark all hardware/IME behavior not actually verified

See `CLAUDE.md`, `docs/requirements.md`, and `docs/basic-design.md`.
'@
    },
    @{
        Title = "feat: implement Release 1 JIS Ohnishi layout core"
        Labels = @("type:feature", "area:core", "release:1")
        Body = @'
## Purpose

Implement the complete JIS-focused Ohnishi layout core using the approach chosen
by the IME technical spike.

## Acceptance criteria

- [ ] AutoHotkey v2.0 only, with `#Requires AutoHotkey v2.0`
- [ ] Complete documented Ohnishi mapping
- [ ] Active only in agreed Japanese romaji composition modes
- [ ] QWERTY in Japanese IME alphanumeric modes
- [ ] Ctrl/Alt/Win input remains QWERTY
- [ ] Shift input works
- [ ] Multiple instances do not cause double remapping
- [ ] Generated events are not remapped again
- [ ] No character chords, timing windows, tap/hold, or normal-key key-up wait
- [ ] Documentation and manual checks are updated

Depends on the IME technical spike.
'@
    },
    @{
        Title = "feat: add resident operation and safe recovery controls"
        Labels = @("type:feature", "area:operations", "release:1")
        Body = @'
## Purpose

Make the script safe and practical for everyday resident use.

## Acceptance criteria

- [ ] Starts with the layout feature enabled
- [ ] Enable/disable command
- [ ] Status command
- [ ] Reload command
- [ ] Emergency exit command that does not require a character key
- [ ] Application exclusion support
- [ ] Startup instructions
- [ ] Recovery and uninstall instructions
- [ ] Normal QWERTY behavior is restored after script exit
- [ ] PowerToys coexistence rules are documented
'@
    },
    @{
        Title = "test: complete Release 1 manual verification"
        Labels = @("type:test", "release:1")
        Body = @'
## Purpose

Complete the minimum practical manual verification for Release 1.

## Acceptance criteria

- [ ] Update `docs/manual-test-checklist.md` with the final behavior
- [ ] Verify JIS IME mode transitions
- [ ] Verify `Ctrl + +` and `Ctrl + -` using the owner's normal JIS operation
- [ ] Verify Shift, repeated keys, key repeat, and overlapping fast typing
- [ ] Verify management hotkeys and recovery
- [ ] File reproducible defects as separate issues
- [ ] Clearly identify tests that were not performed
'@
    },
    @{
        Title = "docs: prepare public Release 1 documentation"
        Labels = @("type:docs", "release:1")
        Body = @'
## Purpose

Prepare the repository for other users after the implementation has passed the
minimum Release 1 verification.

## Acceptance criteria

- [ ] Installation and AutoHotkey prerequisites
- [ ] Configuration and application exclusions
- [ ] Startup, disable, reload, exit, and recovery instructions
- [ ] PowerToys responsibility boundary
- [ ] Supported environment and known limitations
- [ ] No personal paths, usernames, or local-only settings
- [ ] License owner/year reviewed
- [ ] Release 1 tag and release-note proposal
'@
    },
    @{
        Title = "spike: investigate US physical keyboard compatibility for LaTeX"
        Labels = @("type:spike", "area:us-compat", "release:2")
        Body = @'
## Purpose

After Release 1, investigate a separate US physical-keyboard compatibility
layer that works with Japanese IME and reduces Win+Space switching.

## Acceptance criteria

- [ ] Record VK/SC and observed output for priority symbol keys
- [ ] Investigate a reliable backslash position
- [ ] Test LaTeX-priority symbols: `\ [ ] { } ( ) - _ = + ` and `~`
- [ ] Evaluate interaction with Japanese IME modes
- [ ] Evaluate punctuation shortcuts
- [ ] Decide whether the layer materially reduces input-language switching
- [ ] Split implementation into focused Release 2 issues
- [ ] Do not modify Release 1 Core semantics without a separate issue
'@
    }
)

$existingTitles = @{}
$existingJson = gh issue list --state all --limit 200 --json title | ConvertFrom-Json
foreach ($item in $existingJson) {
    $existingTitles[$item.title] = $true
}

foreach ($issue in $issues) {
    if ($existingTitles.ContainsKey($issue.Title)) {
        Write-Host "Skip existing issue: $($issue.Title)"
        continue
    }

    $labelArgs = @()
    foreach ($label in $issue.Labels) {
        $labelArgs += @("--label", $label)
    }

    try {
        gh issue create --title $issue.Title --body $issue.Body @labelArgs | Out-Host
    }
    catch {
        Write-Warning "Issue creation with labels failed. Retrying without labels: $($issue.Title)"
        gh issue create --title $issue.Title --body $issue.Body | Out-Host
    }
}
