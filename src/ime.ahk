#Requires AutoHotkey v2.0
; -----------------------------------------------------------------------------
; IME context plumbing (narrow Windows API layer only).
;
; This file answers exactly one question about the environment:
;   "Is the Japanese IME currently in a kana/katakana composition mode?"
;
; It contains no application policy (enable flag, exclusions, modifier rules).
; Those live with the caller so that Windows API plumbing and behavior policy
; stay separated (see CLAUDE.md section 12).
;
; It never inspects, stores, or logs typed keys or character content. It only
; reads the IME open state and conversion-mode flags of the active window.
;
; Detection method and rationale are recorded in docs/decisions.md (ADR-009).
; -----------------------------------------------------------------------------

class Ime {
    ; WM_IME_CONTROL and the two sub-commands we query.
    static WM_IME_CONTROL        := 0x0283
    static IMC_GETCONVERSIONMODE := 0x0001
    static IMC_GETOPENSTATUS     := 0x0005

    ; Conversion-mode flag bits (imm.h).
    static CMODE_NATIVE    := 0x0001  ; kana input (hiragana/katakana) vs alphanumeric
    static CMODE_KATAKANA  := 0x0002  ; only meaningful together with NATIVE
    static CMODE_FULLSHAPE := 0x0008  ; full-width
    static CMODE_ROMAN     := 0x0010  ; romaji input (as opposed to direct kana input)

    ; Returned when the IME state could not be determined safely. Callers must
    ; treat this as "not composition" and fall back to QWERTY.
    static QUERY_FAILED := -1

    ; HWND of the default IME window that owns the given top-level window's
    ; input thread, or 0 if none.
    static DefaultWindow(hwnd) {
        return DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    }

    ; HWND of the control with input focus in the foreground thread, or the
    ; foreground window itself as a fallback. Querying the focused control
    ; (not just the top-level window) is what makes detection work in modern
    ; apps such as the Windows 11 Notepad (TSF/WinUI), where the top-level
    ; window does not carry the IME state. Verified on real hardware (#14).
    static ActiveInputWindow() {
        fg := DllCall("GetForegroundWindow", "Ptr")
        if !fg
            return 0
        tid := DllCall("GetWindowThreadProcessId", "Ptr", fg, "Ptr", 0, "UInt")
        if tid {
            info := Buffer(8 + 6 * A_PtrSize + 16, 0)   ; GUITHREADINFO
            NumPut("UInt", info.Size, info, 0)          ; cbSize
            if DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", info) {
                focus := NumGet(info, 8 + A_PtrSize, "Ptr")   ; hwndFocus
                if focus
                    return focus
            }
        }
        return fg
    }

    ; Send one WM_IME_CONTROL query. Uses SendMessageTimeout with a short
    ; timeout and SMTO_ABORTIFHUNG so a stuck foreground app can never block
    ; typing; on any failure it returns QUERY_FAILED (-> QWERTY fallback).
    static SendControl(hwnd, subCommand) {
        imeWnd := this.DefaultWindow(hwnd)
        if !imeWnd
            return this.QUERY_FAILED
        result := 0
        ok := DllCall("SendMessageTimeoutW"
            , "Ptr", imeWnd
            , "UInt", this.WM_IME_CONTROL
            , "Ptr", subCommand           ; wParam
            , "Ptr", 0                     ; lParam
            , "UInt", 0x0002               ; SMTO_ABORTIFHUNG
            , "UInt", 20                   ; short timeout: only the cache timer queries (#24)
            , "Ptr*", &result
            , "Ptr")
        return ok ? result : this.QUERY_FAILED
    }

    ; 1 = IME on, 0 = IME off, QUERY_FAILED = could not determine.
    static OpenStatus(hwnd) => this.SendControl(hwnd, this.IMC_GETOPENSTATUS)

    ; Conversion-mode bitmask, or QUERY_FAILED.
    static ConversionMode(hwnd) => this.SendControl(hwnd, this.IMC_GETCONVERSIONMODE)

    ; True only when the IME is on AND in a kana/katakana (NATIVE) mode.
    ; Alphanumeric modes (full/half-width) have NATIVE clear -> false.
    ; Any query failure or unknown state -> false (QWERTY fallback).
    static IsJapaneseComposition(hwnd := 0) {
        if !hwnd
            hwnd := this.ActiveInputWindow()   ; focused control (modern-app safe)
        if !hwnd
            return false
        if (this.OpenStatus(hwnd) != 1)
            return false
        mode := this.ConversionMode(hwnd)
        if (mode = this.QUERY_FAILED)
            return false
        return (mode & this.CMODE_NATIVE) ? true : false
    }

    ; --- Cached composition state (issue #24) --------------------------------
    ; The cross-process WM_IME_CONTROL query is too slow to run on every
    ; keystroke inside the remap predicate: it blocked the keyboard hook and
    ; caused dropped/reordered keys ("メモ帳" -> "あめfもty") during fast typing.
    ; Instead a background timer refreshes this cache and the predicate reads it
    ; instantly. Trade-off: the value can be up to one refresh interval stale,
    ; which only matters within ~one interval of an IME mode switch -- far
    ; shorter than the human gap between switching modes and typing.
    static _composing := false
    static _failCount := 0
    static FAIL_LIMIT := 10   ; consecutive failed queries -> state undeterminable

    ; Cached composition state read by the remap predicate (instant; no query on
    ; the keyboard hook path). A single transient query failure keeps the
    ; last-known value, so it does not cause a spurious QWERTY leak on the next
    ; keystrokes (issue #24). Only after FAIL_LIMIT consecutive failed queries is
    ; the state treated as undeterminable, falling back to QWERTY (CLAUDE.md §7).
    ; Timer starvation during a fast burst attempts no query, so it cannot
    ; false-trip the fallback.
    static Composing {
        get {
            return (this._failCount >= this.FAIL_LIMIT) ? false : this._composing
        }
    }

    static RefreshComposition() {
        hwnd := this.ActiveInputWindow()
        if !hwnd {
            this._failCount++
            return
        }
        open := this.OpenStatus(hwnd)
        if (open = this.QUERY_FAILED) {
            this._failCount++
            return
        }
        if (open != 1) {
            this._composing := false
            this._failCount := 0
            return
        }
        mode := this.ConversionMode(hwnd)
        if (mode = this.QUERY_FAILED) {
            this._failCount++
            return
        }
        this._composing := (mode & this.CMODE_NATIVE) ? true : false
        this._failCount := 0
    }
}
