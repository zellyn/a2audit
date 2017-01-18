;;; Apple II/IIe reset-everything routine
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

!zone resetall {

;;; Reset all soft-switches to known-good state. Burns X and Y, but preserves A.
RESETALL
	tax			; Save A in X until we return
	;; Save return address in Y and A, in case we switch zero-page memory.
	pla
	tay
	pla

	sta _80STORE_OFF_W
	sta RAMRD_OFF_W
	sta RAMWRT_OFF_W
	sta INTCXROM_OFF_W
	sta ALTZP_OFF_W
	sta SLOTC3ROM_OFF_W
	sta SLOTRESET

	;; Restore return address from Y and A.
	pha
	tya
	pha
	txa			; Restore A
	rts
}
