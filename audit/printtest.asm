;;; Helper routines for printing out sequences of test code.
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>


!zone printtest {
	.checkdata = tmp1

PRINTTEST
-
	ldy #0
	lda (PCL),y
	cmp #$20
	beq +++
	lda #'-'
	jsr COUT
	lda #' '
	jsr COUT
	ldx #0
	lda (PCL,x)
	jsr $f88e
	ldx #3
	jsr $f8ea
	jsr $f953
	sta PCL
	sty PCH
	lda #$8D
	jsr COUT
	jmp -
+++	rts

;;; Increment .checkdata pointer to the next memory location, and load
;;; it into the accumulator. X and Y are preserved.
NEXTCHECK
	inc .checkdata
	bne CURCHECK
	inc .checkdata+1
CURCHECK
	sty SCRATCH
	ldy #0
	lda (.checkdata),y
	ldy SCRATCH
	ora #0
	rts

} ;printtest
