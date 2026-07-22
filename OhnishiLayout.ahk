#Requires AutoHotkey v2.0
#SingleInstance Force        ; a second launch replaces the first -> never double-remap
; -----------------------------------------------------------------------------
; Ohnishi IME Layout -- Release 1 JIS Core (Issue #2)
;
; Applies the Ohnishi layout ONLY while ALL of these hold:
;   - the app-level layout switch is enabled
;   - the foreground application is not excluded
;   - no Ctrl / Alt / Win is held (those stay QWERTY, incl. Ctrl+ + / Ctrl+ -)
;   - the Japanese IME is in a kana/katakana composition mode
; Otherwise input is ordinary QWERTY. Shift alone does NOT disable the layout.
; If the IME state cannot be determined, it falls back to QWERTY.
;
; Fast-typing guarantees: no chords, no timing windows, no tap/hold, no key-up
; wait for character output, no timers/sleeps. Generated keys use the default
; send level and never re-trigger the remap. Nothing is logged.
;
; Resident operation controls (enable/disable, status, reload, exit, exclusion
; config, autostart) are added in issue #3.
; -----------------------------------------------------------------------------

#Include %A_ScriptDir%\src\ime.ahk
#Include %A_ScriptDir%\src\ohnishi-map.ahk

KeyHistory 0                 ; never retain a key-history buffer

; --selfcheck: the whole script + includes are parsed at load before this line,
; so this validates syntax then exits without installing a resident session.
if (A_Args.Length >= 1 && A_Args[1] = "--selfcheck")
    ExitApp(0)

; ---- application state (operations UI completed in issue #3) ----------------
global LayoutEnabled := true

; Foreground process names (lowercase, e.g. "game.exe") that stay QWERTY.
; The user-facing exclusion config is completed in issue #3.
global ExcludedProcesses := Map()

; ---- context decision (order follows docs/basic-design.md section 3) --------
ShouldUseOhnishiLayout() {
    global LayoutEnabled
    if !LayoutEnabled
        return false
    if IsExcludedApplication()
        return false
    if AnyBlockingModifierDown()
        return false
    return Ime.IsJapaneseComposition()          ; false on any query failure
}

AnyBlockingModifierDown() {
    return GetKeyState("Ctrl", "P")
        || GetKeyState("Alt", "P")
        || GetKeyState("LWin", "P")
        || GetKeyState("RWin", "P")
}

IsExcludedApplication() {
    global ExcludedProcesses
    if !ExcludedProcesses.Count
        return false
    hwnd := WinExist("A")
    if !hwnd
        return false
    proc := ""
    try proc := WinGetProcessName("ahk_id " hwnd)
    return (proc != "") && ExcludedProcesses.Has(StrLower(proc))
}
