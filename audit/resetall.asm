;;; Apple II/IIe reset-everything routine
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

!zone resetall {

;;; Reset all soft-switches to known-good state. Burns $300 and $301 in main mem.
RESETALL
	sta RESET_RAMRD
	sta RESET_RAMWRT
	stx $300
	sta $301

	;; Save return address in X and A, in case we switch zero-page memory.
	pla
	tax
	pla

	sta RESET_80STORE
	sta RESET_INTCXROM
	sta RESET_ALTZP
	sta RESET_SLOTC3ROM
	sta RESET_INTC8ROM
	sta SET_TEXT
	sta RESET_MIXED
	sta RESET_PAGE2
	sta RESET_HIRES

	;; Restore return address from X and A.
	pha
	txa
	pha

	ldx $300
	lda $301
	rts
}
