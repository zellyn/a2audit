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
	beq .afterlc

.auxlc	;; Run langcard tests in auxmem

	lda LCRESULT
	sta LCRESULT1
	lda #0
	sta LCRESULT
	
	;; Store distinct values in RAM areas, to see if they stay safe.
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$44
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	lda $C083		; Read and write bank 2
	lda $C083
	lda #$44
	sta $D17B

	jsr .zptoaux
	
	sta ALTZP_ON_W
	jsr LANGCARDTESTS_NO_CHECK
	sta ALTZP_OFF_W

	jsr .zpfromaux

	lda LCRESULT
	bne +

	+prerr $0008 ;; E0008: We tried to run the langcard tests again with auxmem (ALTZP active), and they failed, so we're quitting the auxmem test.
	!text "QUITTING AUXMEM TEST DUE TO LC FAIL",$8D
	+prerred
	sec
	rts
	
	;; Check that the stuff we stashed in main RAM was unaffected.
+
	lda $C088		; Read bank 1
	lda $D17B
	cmp #$44
	beq +
	pha
	+print
	!text "WANT BANK1 $D17B"
	+printed
	beq .lcerr

+	lda $C080		; Read bank 2
	lda $D17B
	cmp #$44
	beq +
	pha
	+print
	!text "WANT BANK2 $D17B"
	+printed
	beq .lcerr

+
	lda $FE1F
	cmp #$44
	beq .afterlc
	pha
	+print
	!text "WANT RAM $FE1F"
	+printed

.lcerr
	+print
	!text "=$44;GOT $"
	+printed
	pla
	jsr PRBYTE
	+prerr $0009 ;; E0009: We wrote $44 to main RAM in the three test locations used by the LC test. They should have been unaffected by the LC test while it was using auxmem, but at least one of them was modified.
	!text ""
	+prerred
	sec
	rts
	
.afterlc

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
