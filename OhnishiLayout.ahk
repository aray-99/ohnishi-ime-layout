#Requires AutoHotkey v2.0
#SingleInstance Force        ; a second launch replaces the first -> never double-remap
; -----------------------------------------------------------------------------
; Ohnishi IME Layout -- Release 1 JIS Core
;
; Applies the Ohnishi layout ONLY while ALL of these hold (see src/context.ahk):
;   - the app-level layout switch is enabled
;   - the foreground application is not excluded
;   - no Ctrl / Alt / Win is held (those stay QWERTY, incl. Ctrl+ + / Ctrl+ -)
;   - the Japanese IME is in a kana/katakana composition mode
; Otherwise input is ordinary QWERTY. Shift alone does NOT disable the layout.
; If the IME state cannot be determined, it falls back to QWERTY.
;
; Fast-typing guarantees: no chords, no timing windows, no tap/hold, no key-up
; wait for character output, no timers/sleeps in the character path. Generated
; keys use the default send level and never re-trigger the remap. Nothing is
; logged. On exit, AutoHotkey removes the hotkeys and ordinary QWERTY returns.
;
; Layers:
;   src/ime.ahk         Windows/IME API plumbing (Ime)
;   src/context.ahk     state + decision policy (Layout)
;   src/ohnishi-map.ahk the mapping hotkeys (active while Layout.ShouldApply())
;
; Management (also on the tray icon):
;   Ctrl+Alt+F12  enable/disable      Ctrl+Alt+F11  reload
;   Ctrl+Alt+F10  status              Ctrl+Alt+Esc  emergency exit
; -----------------------------------------------------------------------------

#Include %A_ScriptDir%\src\ime.ahk
#Include %A_ScriptDir%\src\context.ahk
#Include %A_ScriptDir%\src\ohnishi-map.ahk

KeyHistory 0                 ; never retain a key-history buffer

; --selfcheck: everything above is parsed at load before this line, so this
; validates syntax then exits without installing a resident session.
if (A_Args.Length >= 1 && A_Args[1] = "--selfcheck")
    ExitApp(0)

; ---- optional user configuration (exclusions + personal remaps) -------------
; Copy personal.example.ahk to personal.local.ahk (gitignored) and edit there;
; e.g. Layout.Exclude("mstsc.exe"). Missing file is fine (*i = optional).
#Include *i %A_ScriptDir%\personal.local.ahk

; ---- resident operation -----------------------------------------------------
InitTray()
TrayTip("Started and enabled. Ctrl+Alt+F10 = status.", "Ohnishi Layout")

^!F12::ToggleLayout()
^!F11::ReloadLayout()
^!F10::ShowStatus()
^!Esc::ExitApp()

InitTray() {
    A_TrayMenu.Delete()                              ; replace the default menu
    A_TrayMenu.Add("Ohnishi Layout", NoOp)
    A_TrayMenu.Disable("Ohnishi Layout")
    A_TrayMenu.Add()                                 ; separator
    A_TrayMenu.Add("Enabled (Ctrl+Alt+F12)", (*) => ToggleLayout())
    A_TrayMenu.Add("Status (Ctrl+Alt+F10)", (*) => ShowStatus())
    A_TrayMenu.Add("Reload (Ctrl+Alt+F11)", (*) => ReloadLayout())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit (Ctrl+Alt+Esc)", (*) => ExitApp())
    A_TrayMenu.Default := "Status (Ctrl+Alt+F10)"
    UpdateTray()
}

NoOp(*) {
}

ToggleLayout() {
    Layout.Enabled := !Layout.Enabled
    UpdateTray()
    ShowStatus()
}

UpdateTray() {
    if Layout.Enabled
        A_TrayMenu.Check("Enabled (Ctrl+Alt+F12)")
    else
        A_TrayMenu.Uncheck("Enabled (Ctrl+Alt+F12)")
    A_IconTip := "Ohnishi Layout - " (Layout.Enabled ? "enabled" : "disabled")
}

ShowStatus() {
    hwnd := WinExist("A")
    proc := "(none)"
    if hwnd {
        try proc := WinGetProcessName("ahk_id " hwnd)
    }
    comp := Ime.IsJapaneseComposition(hwnd)
    excl := Layout.IsExcludedApp()
    msg := "Ohnishi Layout: " (Layout.Enabled ? "ENABLED" : "DISABLED")
        . "`nIME composition: " (comp ? "yes -> Ohnishi" : "no -> QWERTY")
        . "`nApp: " proc (excl ? "  [excluded]" : "")
    ShowTip(msg, 2600)
}

ShowTip(text, ms) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -ms)
}

ReloadLayout() {
    Reload()
}
