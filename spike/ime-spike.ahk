#Requires AutoHotkey v2.0
#SingleInstance Force
; -----------------------------------------------------------------------------
; SPIKE harness for issue #1 -- NOT the production core.
;
; Purpose:
;   1. Observe the Japanese IME open state and conversion mode live, so the
;      owner can record real values for each IME mode.
;   2. Validate that a small context-sensitive remap delivers romaji keys to
;      the IME correctly, bypasses on Ctrl/Alt/Win, and behaves under Shift,
;      key repeat, and overlapping fast typing.
;   3. Optionally identify the VK/SC of a single physical key, so JIS symbol
;      key positions can be confirmed (see CLAUDE.md section 9).
;
; This harness stores and logs nothing. The observer only reads IME state; the
; identify tool reports one key you deliberately press and keeps no history.
;
; Controls:
;   Ctrl+Alt+R  toggle the 3-key experimental remap on/off
;   Ctrl+Alt+I  identify one physical key (VK/SC) once
;   Ctrl+Alt+Q  quit the spike
; -----------------------------------------------------------------------------

#Include %A_ScriptDir%\..\src\ime.ahk

; Static self-check: the whole script (and its includes) is parsed at load
; before this line runs, so this validates syntax then exits without showing
; the panel or holding the keyboard hook.  Run: AutoHotkey64.exe ime-spike.ahk --selfcheck
if (A_Args.Length >= 1 && A_Args[1] = "--selfcheck")
    ExitApp(0)

KeyHistory 0                 ; do not retain a key-history buffer
global SpikeRemapOn := true

; --- Live observer panel (never takes keyboard focus) -----------------------
obs := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x08000000")   ; WS_EX_NOACTIVATE
obs.MarginX := 14, obs.MarginY := 12
obs.BackColor := "101418"
obs.SetFont("s10", "Consolas")
global ObsText := obs.AddText("cCCCCCC w580 r10", "Starting IME spike...")
obs.Show("x12 y12 NoActivate")
SetTimer(UpdateObserver, 200)

UpdateObserver(*) {
    hwnd := WinExist("A")
    proc := "(none)"
    if hwnd {
        try proc := WinGetProcessName("ahk_id " hwnd)
    }
    open := hwnd ? Ime.OpenStatus(hwnd) : Ime.QUERY_FAILED
    mode := hwnd ? Ime.ConversionMode(hwnd) : Ime.QUERY_FAILED
    comp := Ime.IsJapaneseComposition(hwnd)

    lines := []
    lines.Push("Ohnishi IME Spike  (issue #1)")
    lines.Push("-----------------------------------------------")
    lines.Push("Active window : " proc)
    lines.Push("IME open      : " FormatOpen(open))
    lines.Push("Conversion    : " FormatMode(mode))
    lines.Push("Composition?  : " (comp ? "YES  -> Ohnishi would apply" : "no   -> QWERTY"))
    lines.Push("3-key remap   : " (SpikeRemapOn ? "ON  (D->A  F->O  J->T)" : "OFF"))
    lines.Push("-----------------------------------------------")
    lines.Push("Ctrl+Alt+R toggle   Ctrl+Alt+I identify   Ctrl+Alt+Q quit")
    ObsText.Value := Join(lines, "`n")
}

FormatOpen(v) {
    if (v = Ime.QUERY_FAILED)
        return "unavailable -> fallback QWERTY"
    return v = 1 ? "1 (on)" : "0 (off)"
}

FormatMode(v) {
    if (v = Ime.QUERY_FAILED)
        return "unavailable -> fallback QWERTY"
    flags := []
    if (v & Ime.CMODE_NATIVE)
        flags.Push("NATIVE")
    if (v & Ime.CMODE_KATAKANA)
        flags.Push("KATAKANA")
    if (v & Ime.CMODE_FULLSHAPE)
        flags.Push("FULLSHAPE")
    if (v & Ime.CMODE_ROMAN)
        flags.Push("ROMAN")
    label := flags.Length ? Join(flags, " ") : "ALPHANUMERIC"
    return Format("0x{:04X}  [{}]", v, label)
}

Join(arr, sep) {
    s := ""
    for i, v in arr
        s .= (i > 1 ? sep : "") v
    return s
}

; --- Experimental remap: only in Japanese composition, never with Ctrl/Alt/Win
SpikeShouldRemap() {
    global SpikeRemapOn
    if !SpikeRemapOn
        return false
    if GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P")
        || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
        return false
    return Ime.IsJapaneseComposition()
}

#HotIf SpikeShouldRemap()
*d::Send "{Blind}a"
*f::Send "{Blind}o"
*j::Send "{Blind}t"
#HotIf

; --- Management hotkeys (work regardless of IME state) -----------------------
^!r::ToggleRemap()
^!i::IdentifyKey()
^!q::ExitApp()

ToggleRemap(*) {
    global SpikeRemapOn
    SpikeRemapOn := !SpikeRemapOn
    UpdateObserver()
}

IdentifyKey(*) {
    ToolTip("IDENTIFY: release Ctrl/Alt, then press ONE physical key.`nNothing is typed or stored.")
    ih := InputHook()
    ih.KeyOpt("{All}", "NS")          ; notify + suppress every key
    ih.OnKeyDown := IdentifyKeyDown
    ih.Start()
}

IdentifyKeyDown(ih, vk, sc) {
    ih.Stop()
    name := GetKeyName(Format("vk{:X}sc{:X}", vk, sc))
    ToolTip(Format("VK = 0x{:02X}    SC = 0x{:03X}    Name = {}`n(nothing typed, nothing stored)", vk, sc, name))
    SetTimer(RemoveTip, -3500)
}

RemoveTip(*) => ToolTip()
