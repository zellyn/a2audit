;;; Apple II keyboard and keyboard audit routines
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

	!zone keyboard {
KEYBOARDTESTS
	+print
	!text "PRESS 'Y', 'N', SPACE, OR ESC",$8D
	+printed
	jsr YNESCSPACE
	rts

YNESCSPACE
	lda KBDSTRB
--	lda KBD
	bpl --
	sta KBDSTRB
	cmp #$a0		; SPACE: bmi/bcc
	bne +
	clc
	lda #$a0
	rts
+	cmp #$9B		; ESC: bmi/bcs
	bne +
	sec
	lda #$9B
	rts
+	and #$5f		; mask out lowercase
	cmp #$59		; 'Y': bpl/bcc
	bne +
	clc
	lda #$59
	rts
+	cmp #$4e		; 'N': bpl/bcs
	bne --
	sec
	lda #$4e
	rts

} ;keyboard
