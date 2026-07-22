#Requires AutoHotkey v2.0
; -----------------------------------------------------------------------------
; Remap context: application state + the decision of whether to apply the
; Ohnishi layout right now. This is the policy layer, kept separate from the
; Windows/IME plumbing in src/ime.ahk (CLAUDE.md section 12).
;
; Must be #Included after src/ime.ahk (it calls Ime.IsJapaneseComposition()).
; Holds no hotkeys, so it can be loaded and exercised on its own.
;
; Decision order follows docs/basic-design.md section 3.
; -----------------------------------------------------------------------------

class Layout {
    ; Application-level switch. Starts enabled (Release 1 requirement R1-07).
    static Enabled := true

    ; Set of foreground process names (lowercase) that must stay QWERTY.
    static Excluded := Map()

    ; Add one or more process names to the exclusion set, e.g.
    ;   Layout.Exclude("mstsc.exe", "somegame.exe")
    static Exclude(names*) {
        for name in names
            this.Excluded[StrLower(name)] := true
    }

    ; True when the foreground application is excluded from remapping.
    static IsExcludedApp() {
        if !this.Excluded.Count
            return false
        hwnd := WinExist("A")
        if !hwnd
            return false
        proc := ""
        try proc := WinGetProcessName("ahk_id " hwnd)
        return (proc != "") && this.Excluded.Has(StrLower(proc))
    }

    ; True while any layout-disabling modifier is physically held. Shift is not
    ; included: Shift alone keeps the Ohnishi layout (requirement R1-05).
    static AnyBlockingModifier() {
        return GetKeyState("Ctrl", "P")
            || GetKeyState("Alt", "P")
            || GetKeyState("LWin", "P")
            || GetKeyState("RWin", "P")
    }

    ; The single predicate used by the remap hotkeys. Cheap checks first.
    static ShouldApply() {
        if !this.Enabled
            return false
        if this.IsExcludedApp()
            return false
        if this.AnyBlockingModifier()
            return false
        return Ime.IsJapaneseComposition()        ; false on any query failure
    }
}
