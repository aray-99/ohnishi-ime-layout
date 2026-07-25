#Requires AutoHotkey v2.0
; -----------------------------------------------------------------------------
; Ohnishi physical-to-logical mapping (Issue #2).
;
; #Included by OhnishiLayout.ahk; not run standalone (it depends on
; Layout.ShouldApply(), defined in src/context.ahk).
;
; Each hotkey suppresses the physical key and sends the logical key with
; {Blind}, so Shift produces the corresponding uppercase/symbol and no timing,
; chord, tap/hold, or key-up wait is involved. The default send level is kept,
; so a sent key never re-triggers these hotkeys (no re-remapping).
;
; Identity keys (Q P Z X C V) are intentionally omitted -- they already type
; themselves. Complete mapping (CLAUDE.md section 8):
;
;   Physical: Q W E R T Y U I O P    A S D F G H J K L ;    Z X C V B N M , . /
;   Logical:  Q L U , . F W R Y P    E I A O - K T N S H    Z X C V ; G D M J B
;
; Plus the number-row '-' key (minus, above @ on JIS) -> '/' (issue #23).
;
; Source keys: letters by letter; the punctuation keys by SCAN CODE so the
; correct PHYSICAL keys are captured on a JIS keyboard. Symbol targets are sent
; as literal characters so AutoHotkey maps them to the active layout (ADR-011).
; -----------------------------------------------------------------------------

#HotIf Layout.ShouldApply()

; Row 1:  Q W E R T Y U I O P  ->  Q L U , . F W R Y P   (Q, P identity)
*w::Send "{Blind}l"
*e::Send "{Blind}u"
*r::Send "{Blind},"
*t::Send "{Blind}."
*y::Send "{Blind}f"
*u::Send "{Blind}w"
*i::Send "{Blind}r"
*o::Send "{Blind}y"

; Row 2:  A S D F G H J K L ;  ->  E I A O - K T N S H
*a::Send "{Blind}e"
*s::Send "{Blind}i"
*d::Send "{Blind}a"
*f::Send "{Blind}o"
*g::Send "{Blind}-"
*h::Send "{Blind}k"
*j::Send "{Blind}t"
*k::Send "{Blind}n"
*l::Send "{Blind}s"
*SC027::Send "{Blind}h"      ; physical ';' key  ->  H

; Row 3:  Z X C V B N M , . /  ->  Z X C V ; G D M J B   (Z, X, C, V identity)
*b::Send "{Blind};"
*n::Send "{Blind}g"
*m::Send "{Blind}d"
*SC033::Send "{Blind}m"      ; physical ',' key  ->  M
*SC034::Send "{Blind}j"      ; physical '.' key  ->  J
*SC035::Send "{Blind}b"      ; physical '/' key  ->  B

; Number row:  physical '-' (minus, above @ on JIS)  ->  '/'   (issue #23)
*SC00C::Send "{Blind}/"

#HotIf
