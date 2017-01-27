;;; Apple IIe softswitch-reading tests
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

!zone softswitch {

	.resetloc = tmp1
	.setloc = tmp3
	.readloc = tmp5
	.loopcount = tmp0
	.switch = SRC
	.testtimes = 8
	
SOFTSWITCHTESTS
	lda #1
	sta SOFTSWITCHRESULT

	lda MACHINE
	cmp #4
	bcs +
	+print
	!text "NOT IIE OR IIC:SKIPPING SOFTSWITCH TEST",$8D
	+printed
	sec
	rts

+	+print
	!text "TESTING SOFTSWITCHES",$8D
	+printed

	;; Test write-softswitches
	lda #<.writeswitches
	sta SRC
	lda #>.writeswitches
	sta SRC+1
	lda #(.readswitches-.writeswitches)/6
	sta .loopcount

.wrtloop
	;; Copy reset/set/read locations to .resetloc, .setloc, .readloc
	ldy #0
	ldx #0
-	lda (SRC),y
	sta .resetloc,x
	inc SRC
	bne +
	inc SRC+1
+	inx
	cpx #6
	bne -

	jsr RESETALL
	jsr zptoaux
	
	;; Initial RESET
	ldy #0
	sta (.resetloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bpl +			;ok
	ldx #$80
	jsr RESETALL
	jsr .fail
	beq .wrtloopend
+	dex
	bne -

	;; Ensure that reading doesn't do anything.
	ldy #0
	lda (.setloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bpl +			;ok
	ldx #$42
	jsr RESETALL
	jsr .fail
	beq .wrtloopend
+	dex
	bne -

	;; Actual SET
	ldy #0
	sta (.setloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bmi +			;ok
	ldx #$82
	jsr RESETALL
	jsr .fail
	beq .wrtloopend
+	dex
	bne -

	;; RESET again
	ldy #0
	sta (.resetloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bpl +			;ok
	ldx #$80
	jsr RESETALL
	jsr .fail
	beq .wrtloopend
+	dex
	bne -

.wrtloopend
	dec .loopcount
	bne .wrtloop

	lda #(.endswitches-.readswitches)/6
	sta .loopcount
	
	
.readloop
	;; Copy reset/set/read locations to .resetloc, .setloc, .readloc
	ldy #0
	ldx #0
-	lda (SRC),y
	sta .resetloc,x
	inc SRC
	bne +
	inc SRC+1
+	inx
	cpx #6
	bne -

	jsr RESETALL
	jsr zptoaux
	
	;; Initial RESET
	ldy #0
	lda (.resetloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bpl +			;ok
	ldx #$00
	jsr RESETALL
	jsr .fail
	beq .readloopend
+	dex
	bne -

	;; Actual SET
	ldy #0
	lda (.setloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bmi +			;ok
	ldx #$02
	jsr RESETALL
	jsr .fail
	beq .readloopend
+	dex
	bne -

	;; RESET again
	ldy #0
	lda (.resetloc),y
	ldx #.testtimes		; test `.testtimes` times
-	lda (.readloc),y
	bpl +			;ok
	ldx #$00
	jsr RESETALL
	jsr .fail
	beq .readloopend
+	dex
	bne -

.readloopend
	dec .loopcount
	bne .readloop


.end
	jsr RESETALL
	lda SOFTSWITCHRESULT
	bne .success
	sec
	rts
.success	
	+print
	!text "SOFTSWITCH TESTS SUCCEEDED",$8D
	+printed
	clc
	rts

;;; Print failure message.
;;; High bit of X = write. Low two bits of X: 0 = .resetloc, 2 = .setloc
;;; A = actual value read (which tells what we expected: the opposite)
.fail
	sta SCRATCH
	stx SCRATCH2
	txa
	bmi +
	+print
	!text "READ"
	+printed
	beq ++
+	+print
	!text "WRITE"
	+printed
++	+print
	!text " AT "
	+printed
	txa
	and #$3
	tax
	ldy .resetloc+1,x
	lda .resetloc,x
	tax
	jsr PRNTYX
	+print
	!text " SHOULD "
	+printed
	lda SCRATCH2
	and #$40
	beq +
	+print
	!text "NOT SET "
	+printed
	beq ++
+	lda SCRATCH
	bpl +
	+print
	!text "RE"
	+printed
+	+print
	!text "SET "
	+printed
++	ldx .readloc
	ldy .readloc+1
	jsr PRNTYX
	+print
	!text ";GOT " 
	+printed
	lda SCRATCH
	jsr PRBYTE
	lda #$8D
	jsr COUT
	lda #0
	sta SOFTSWITCHRESULT
	rts
	
.writeswitches
	!word RESET_80STORE, SET_80STORE, READ_80STORE
	!word RESET_RAMRD, SET_RAMRD, READ_RAMRD
	!word RESET_RAMWRT, SET_RAMWRT, READ_RAMWRT
	!word RESET_INTCXROM, SET_INTCXROM, READ_INTCXROM
	!word RESET_ALTZP, SET_ALTZP, READ_ALTZP
	!word RESET_SLOTC3ROM, SET_SLOTC3ROM, READ_SLOTC3ROM
	!word RESET_80COL, SET_80COL, READ_80COL
	!word RESET_ALTCHRSET, SET_ALTCHRSET, READ_ALTCHRSET
.readswitches
	!word RESET_TEXT, SET_TEXT, READ_TEXT
	!word RESET_MIXED, SET_MIXED, READ_MIXED
	!word RESET_PAGE2, SET_PAGE2, READ_PAGE2
	!word RESET_HIRES, SET_HIRES, READ_HIRES
.endswitches
} ;softswitch
