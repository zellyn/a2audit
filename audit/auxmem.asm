;;; Apple IIe Auxiliary memory audit routines
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

	!zone auxmem {
AUXMEMTESTS
	lda #0
	sta AUXRESULT
	lda MEMORY
	cmp #65
	bcs +
	+print
	!text "64K OR LESS:SKIPPING AUXMEM TEST",$8D
	+printed
	sec
	rts

+	+print
	!text "TESTING AUX MEM",$8D
	+printed

	lda LCRESULT
	bne .auxlc
	+print
	!text "LC FAILED BEFORE:SKIPPING AUXMEM LC",$8D
	+printed
	beq .skiplc

.auxlc	;; Run langcard tests in auxmem

	lda LCRESULT
	sta LCRESULT2
	lda #0
	sta LCRESULT
	
	;; Store distinct values in RAM areas, to see if they stay safe.
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$44
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	lda #$55
	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	lda $C083		; Read and write bank 2
	lda $C083
	lda #$66
	sta $D17B

	jsr .zptoaux
	
	sta ALTZP_ON_W
	jsr LANGCARDTESTS_NO_CHECK
	sta ALTZP_OFF_W

	jsr .zpfromaux
	
.skiplc

	;; Success
	+print
	!text "AUXMEM TESTS SUCCEEDED",$8D
	+printed
	lda #1
	sta AUXRESULT
	clc
.done
	rts


;;; Copy zero page to aux mem. Assumes zp pointing at main mem, and leaves it that way.
.zptoaux
	ldx #0
-	sta ALTZP_OFF_W
	lda 0,x
	sta ALTZP_ON_W
	sta 0,x
	inx
	bne -
	sta ALTZP_OFF_W
	rts

;;; Copy zero page from aux mem. Assumes zp pointing at main mem, and leaves it that way.
.zpfromaux
	ldx #0
-	sta ALTZP_ON_W
	lda 0,x
	sta ALTZP_OFF_W
	sta 0,x
	inx
	bne -
	rts

} ;auxmem
