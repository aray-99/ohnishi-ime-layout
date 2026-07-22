#Requires AutoHotkey v2.0
; -----------------------------------------------------------------------------
; Personal, machine-local configuration EXAMPLE.
;
; Copy this file to `personal.local.ahk` (gitignored) in the repository root.
; OhnishiLayout.ahk loads `personal.local.ahk` automatically if it exists.
; This example file itself is NOT loaded.
;
; Nothing here is required. Use it only to customize your own machine.
; -----------------------------------------------------------------------------

; --- Application exclusions --------------------------------------------------
; Foreground processes that must always stay QWERTY (never remapped), even in
; Japanese composition mode. Names are matched case-insensitively.
;
;   Layout.Exclude("mstsc.exe")            ; Remote Desktop
;   Layout.Exclude("someGame.exe", "vmware.exe")

; --- Optional personal remaps ------------------------------------------------
; Any personal hotkeys may go here.
;
; Release 1 intentionally leaves the owner's CapsLock / 半角・全角 swap in
; PowerToys. Do NOT remap the same physical key in both PowerToys and
; AutoHotkey. If you ever migrate it here, disable it in PowerToys first.
