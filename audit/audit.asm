;;; Apple II audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!convtab <apple ii/convtab.bin>
	!to "audit.o", plain
	* = $6000
	START = *

	;; Zero-page locations.
	SCRATCH = $1
	LCRESULT = $10
	LCRESULT1 = $11
	AUXRESULT = $12

	CSW = $36
	KSW = $38

	PCL=$3A
	PCH=$3B

	;; AUXMOVE locations
	;; $3C
	;; $3D
	;; $3E
	;; $3F
	;; $42
	;; $43

	;; SHASUM locations
	!addr	SRC = $06
	!addr	DST = $08
	!addr   SHAINPUT = $eb
	!addr   SHALENGTH = $ee
	!addr   tmp1 = $fa
	!addr   tmp2 = $fb
	!addr   tmp3 = $fc
	!addr   tmp4 = $fd
	!addr   tmp5 = $fe

	;; Softswitch locations.
	RESET_80STORE = $C000
	SET_80STORE = $C001
	READ_80STORE = $C018

	RESET_RAMRD = $C002
	SET_RAMRD = $C003
	READ_RAMRD = $C013

	RESET_RAMWRT = $C004
	SET_RAMWRT = $C005
	READ_RAMWRT = $C014

	RESET_INTCXROM = $C006
	SET_INTCXROM = $C007
	READ_INTCXROM = $C015

	RESET_ALTZP = $C008
	SET_ALTZP = $C009
	READ_ALTZP = $C016

	RESET_SLOTC3ROM = $C00A
	SET_SLOTC3ROM = $C00B
	READ_SLOTC3ROM = $C017

	RESET_TEXT = $C050
	SET_TEXT = $C051
	READ_TEXT = $C01A

	RESET_MIXED = $C052
	SET_MIXED = $C053
	READ_MIXED = $C01B
	
	RESET_PAGE2 = $C054
	SET_PAGE2 = $C055
	READ_PAGE2 = $C01C
	
	RESET_HIRES = $C056
	SET_HIRES = $C057
	READ_HIRES = $C01D
	
	RESET_INTC8ROM = $CFFF

	;; CXXX utility routine locations
	AUXMOVE = $C311
	;; Monitor locations.
	HOME = $FC58
	COUT = $FDED
	COUT1 = $FDF0
	KEYIN = $FD1B
	CROUT = $FD8E
	PRBYTE = $FDDA
	PRNTYX = $F940

	STRINGS = $7000
	!set LASTSTRING = $7000

	;; Printing and error macros.
	!src "macros.asm"

main:
	;; Initialize stack to the top.
	ldx #$ff
	txs
	
	jsr standard_fixup

	jsr HOME
	+print
	!text "APPLE II AUDIT",$8D,$8D
	+printed

	;; Detection and reporting of model and memory.
	!src "detect.asm"

	;; Language card tests.
	jsr LANGCARDTESTS

	;; Auxiliary memory card tests.
	jsr AUXMEMTESTS

	;; ROM SHA-1 checks.
	;; jsr SHASUMTESTS - do this later, because it's SLOW!

end:
	+print
	!text "END"
	+printed
	jmp *

	!src "langcard.asm"
	!src "auxmem.asm"
	;!src "shasumtests.asm"
	!src "resetall.asm"

print
	lda $C081
	lda $C081
	pla
	sta getch+1
	pla
	sta getch+2
-	inc getch+1
	bne getch
	inc getch+2
getch	lda $FEED		; FEED gets modified
	beq +
	jsr COUT
	jmp -
+	rts

;;; Print a string of bytes, as hex.
;;; Address in SRC, count in A.
;;; Burns A,Y.
prbytes:
	ldy #0
-	pha
	lda (SRC),y
	jsr PRBYTE
	iny
	pla
	adc #$ff
	bne -
	rts


errora
	pha
	lda $C082
	lda #'A'
	jsr COUT
	lda #':'
	jsr COUT
	pla
	jsr PRBYTE
	jsr CROUT
error
	lda $C082
	pla
	sta getche+1
	pla
	sta getche+2
-	inc getche+1
	bne getche
	inc getche+2
getche	lda $FEED		; FEED gets modified
	beq +
	jsr COUT
	jmp -
+
	+print
	!text "ZELLYN.COM/A2AUDIT/V0#E",0
	+printed
	jsr PRNTYX
	lda #$8D
	jsr COUT
rts
	!src "technote2.asm"
	;!src "../shasum/shasum.asm"

;;; If we loaded via standard delivery, turn the motor off and fix up
;;; CSW and KSW (in case the user typed PR#6 or IN#6 to boot).
standard_fixup:
	;; TODO(zellyn): actually check for standard delivery.
	;; Turn drive motor off - do this regardless, since it doesn't hurt.
	ldx $2B
	lda $C088,X

	;; If we typed PR#6 or IN#6 or something similar, the low byte
	;; of CSW or KSW will be 0.

	;; Fixup CSW
	lda CSW
	bne +
	;; Point COUT at COUT1
	lda #<COUT1
	sta CSW
	lda #>COUT1
	sta CSW+1

	;; Fixup KSW
+	lda KSW
	bne +
	lda #<KEYIN
	sta KSW
	lda #>KEYIN
	sta KSW+1
+	rts

COPYTOAUX
	;; Use AUXMOVE routine to copy the whole program to AUX memory.
	sta RESET_SLOTC3ROM
	lda #<START
	sta $3C
	sta $42
	lda #>START
	sta $3D
	sta $43
	lda #<(LASTSTRING-1)
	sta $3E
	lda #>(LASTSTRING-1)
	sta $3F
	sec			; Move from main to aux memory.
	jsr AUXMOVE
	rts
	
;	!if * != STRINGS {
;	!error "Expected STRINGS to be ", *
;	}

	!if * > STRINGS {
	!error "End of compilation passed STRINGS:", *
	}
