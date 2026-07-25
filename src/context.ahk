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

    ; True while any layout-disabling modifier is held. Shift is not included:
    ; Shift alone keeps the Ohnishi layout (requirement R1-05).
    ;
    ; Uses the logical key state (not physical "P"), so a modifier produced by
    ; another remapper -- e.g. PowerToys mapping 無変換 to Ctrl -- is also
    ; detected. Such injected modifiers do not register as physical, which
    ; otherwise let the remap fire under Ctrl (無変換+D -> Ctrl+A). Verified on
    ; real hardware (#14).
    static AnyBlockingModifier() {
        return GetKeyState("Ctrl")
            || GetKeyState("Alt")
            || GetKeyState("LWin")
            || GetKeyState("RWin")
    }

    ; The single predicate used by the remap hotkeys. Cheap checks first.
    static ShouldApply() {
        if !this.Enabled
            return false
        if this.IsExcludedApp()
            return false
        if this.AnyBlockingModifier()
            return false
        return Ime.Composing        ; fast cached state (refreshed by a timer); #24
    }
}
