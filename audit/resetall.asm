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

	sta _80STORE_OFFW
	sta RAMRD_OFFW
	sta RAMWRT_OFFW
	sta INTCXROM_OFFW
	sta ALTZP_OFFW
	sta SLOTC3ROM_OFFW
	sta SLOTRESET

	;; Restore return address from Y and A.
	pha
	tya
	pha
	txa			; Restore A
	rts
}
