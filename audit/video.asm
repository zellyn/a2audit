;;; Apple II video audit routines
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

	!zone video {
VIDEOTESTS

	jsr RESETALL

	+print
	!text "VIDEO TESTS:",$8D
	!text "SPACE TO SWAP BETWEEN MODES",$8D
	!text "Y/N TO LOG MODE EQUALITY & MOVE TO NEXT",$8D
	!text "ESC TO SKIP TO END",$8D
	!text "HIT SPACE TO START",$8D
	+printed

-	jsr YNESCSPACE
	bpl -
	bcs -

	jsr .first

;;; Main loop over test data. Quit when high addr of text to be printed is $ff.
---
	jsr RESETALL
	jsr HOME
	jsr .this
	sta getch+1
	jsr .next
	sta getch+2
	cmp #$ff
	beq .done
	jsr getch

	jsr YNESCSPACE
	cmp #$9B
	beq .done

	jsr .next
	jsr .load400aux
	jsr .load400

	jsr .load2000aux
	jsr .load2000

	ldx #0

--	;; Loop back and forth between modes as "space" is pressed.
	jsr .setswitches
	txa
	eor #1
	tax
	jsr YNESCSPACE

	bpl +
	cmp #$a0
	beq --
	jmp .done		; ESC

+	;; 'Y' or 'N'

	jsr .next
	jsr .next
	cmp #$ff
	bne ---

.done   jsr RESETALL
	jsr HOME
	rts

.setswitches
	jsr .thisx

	;; 0: TEXT
	lsr
	bcs +
	sta RESET_TEXT
	bcc ++
+	sta SET_TEXT

++	;; 1: MIXED
	lsr
	bcs +
	sta RESET_MIXED
	bcc ++
+	sta SET_MIXED

++	;; 2: HIRES
	lsr
	bcs +
	sta RESET_HIRES
	bcc ++
+	sta SET_HIRES

++	;; 3: 80COL
	lsr
	bcs +
	sta RESET_80COL
	bcc ++
+	sta SET_80COL

++	;; 4: (NOT) AN3
	lsr
	bcs +
	sta SET_AN3
	bcc ++
+	sta RESET_AN3

++	;; 5: ALTCHRSET
	lsr
	bcs +
	sta RESET_ALTCHRSET
	bcc ++
+	sta SET_ALTCHRSET

++	;; 6: PAGE2
	lsr
	bcs +
	sta RESET_PAGE2
	bcc ++
+	sta SET_PAGE2

++	;; 7: 80STORE
	lsr
	bcs +
	sta RESET_80STORE
	rts
+	sta SET_80STORE
	rts

.load
	;; A1L/A1H is start addr
	;; tmp0 is # pages
	;; tmp1 is even
	;; tmp2 is odd

	;; During loop:
	;; PCL/PCH is looper
	;; y is index
	;; X is # pages

	lda A1L
	sta PCL
	lda A1H
	sta PCH
	ldx tmp0
	lda tmp1
	ldy #0

-	sta (PCL),y
	iny
	iny
	bne -
	inc PCH
	dex
	bne -

	lda A1H
	sta PCH
	inc PCL
	ldx tmp0
	lda tmp2
	ldy #0

-	sta (PCL),y
	iny
	iny
	bne -
	inc PCH
	dex
	bne -

	rts

;;; Read next even/odd values and store them for .load in tmp1/tmp2
.evenodd
	jsr .this
	sta tmp1
	jsr .next
	sta tmp2
	jsr .next
	rts

;;; Setup A1L, A1H, and tmp0 for fill of $400-$7FF
.set400
	lda #<$400
	sta A1L
	lda #>$400
	sta A1H
	lda #4
	sta tmp0
	rts

;;; Setup A1L, A1H, and tmp0 for fill of $2000-$3fff
.set2000
	lda #<$2000
	sta A1L
	lda #>$2000
	sta A1H
	lda #$20
	sta tmp0
	rts

.load400
	jsr .evenodd
	jsr .set400
	jsr .load
	rts

.load400aux
	jsr .evenodd
	jsr .set400
	sta SET_RAMWRT
	jsr .load
	sta RESET_RAMWRT
	rts

.load2000
	jsr .evenodd
	jsr .set2000
	jsr .load
	rts

.load2000aux
	jsr .evenodd
	jsr .set2000
	sta SET_RAMWRT
	jsr .load
	sta RESET_RAMWRT
	rts


.first
	lda #<.testdata
	sta .thisx+1
	lda #>.testdata
	sta .thisx+2
	rts
.next
	lda .testdata
	inc .thisx+1
	bne .this
	inc .thisx+2
.this	ldx #0
.thisx  lda .testdata,x
	rts

	;; Mode bits:
	;; 0: TEXT
	;; 1: MIXED
	;; 2: HIRES
	;; 3: 80COL
	;; 4: (NOT) AN3
	;; 5: ALTCHRSET
	;; 6: PAGE2
	;; 7: 80STORE
	.md_text      = $01
	.md_mixed     = $02
	.md_hires     = $04
	.md_80col     = $08
	.md_an3off    = $10
	.md_altchrset = $20
	.md_page2     = $40
	.md_80store   = $80

foo	!text "FOOBAR",$8D,$0

.testdata
	;; Aux lores even/odd, lores even/odd, aux hires even/odd, hires even/odd, mode 1, mode 2

	;; 40COL and 80COL Text, inverse space.
	+string
	!text "40-COL AND 80-COL TEXT INVERSE SPACES:",$8D
	!text "ALL WHITE, WITH 1/80 SHIFT LEFT"
	+stringed
	!byte $20, $20, $20, $20, 0, 0, 0, 0, .md_text, .md_text | .md_80col

	;; LORES patterns that correspond to HIRES patterns.
	+string
	!text "LORES VIOLET, HIRES VIOLET:SAME"
	+stringed
	!byte 0, 0, $33, $33, 0, 0, $55, $2a, 0, .md_hires ; purple
	+string
	!text "LORES GREEN, HIRES GREEN:SAME"
	+stringed
	!byte 0, 0, $cc, $cc, 0, 0, $2a, $55, 0, .md_hires ; green
	+string
	!text "LORES LIGHT BLUE, HIRES LIGHT BLUE:SAME"
	+stringed
	!byte 0, 0, $66, $66, 0, 0, $d5, $aa, 0, .md_hires ; light blue
	+string
	!text "LORES ORANGE, HIRES ORANGE:LEFT",$8D
	!text "EDGE SHIFTS RIGHT A COUPLE OF PIXELS"
	+stringed
	!byte 0, 0, $99, $99, 0, 0, $aa, $d5, 0, .md_hires ; orange - left column should budge

	;; LORES patterns and corresponding DBL HIRES patterns.
	+string
	!text "LORES AND DBL HIRES DARK MAGENTA:SHIFT",$8D
	!text "LEFT"
	+stringed
	!byte 0, 0, $11, $11, $88, $22, $11, $44, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES DARK BLUE:SHIFT LEFT"
	+stringed
	!byte 0, 0, $22, $22, $11, $44, $22, $88, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES VIOLET:SHIFT LEFT"
	+stringed
	!byte 0, 0, $33, $33, $99, $66, $33, $cc, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES DARK BLUEGREEN:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $44, $44, $22, $88, $44, $11, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES GRAY $5:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $55, $55, $aa, $aa, $55, $55, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES BLUE:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $66, $66, $33, $cc, $66, $99, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES LIGHT BLUE:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $77, $77, $bb, $ee, $77, $dd, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES DARK BROWN:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $88, $88, $44, $11, $88, $22, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES ORANGE:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $99, $99, $cc, $33, $99, $66, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES GRAY $A:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $aa, $aa, $55, $55, $aa, $aa, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES LIGHT MAGENTA:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $bb, $bb, $dd, $77, $bb, $ee, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES GREEN:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $cc, $cc, $66, $99, $cc, $33, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES LIGHT BROWN:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $dd, $dd, $ee, $bb, $dd, $77, 0, .md_hires | .md_80col | .md_an3off
	+string
	!text "LORES AND DBL HIRES LIGHT BLUEGREEN:",$8D
	!text "SHIFT LEFT"
	+stringed
	!byte 0, 0, $ee, $ee, $77, $dd, $ee, $bb, 0, .md_hires | .md_80col | .md_an3off

	;; DBL LORES patterns and corresponding DBL HIRES patterns.
	+string
	!text "DBL LORES AND DBL HIRES DARK MAGENTA:",$8D
	!text "SAME"
	+stringed
	!byte $88, $88, $11, $11, $88, $22, $11, $44, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES DARK BLUE:SAME"
	+stringed
	!byte $11, $11, $22, $22, $11, $44, $22, $88, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES VIOLET:SAME"
	+stringed
	!byte $99, $99, $33, $33, $99, $66, $33, $cc, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES DARK BLUEGREEN:",$8D
	!text "SAME"
	+stringed
	!byte $22, $22, $44, $44, $22, $88, $44, $11, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES GRAY $5:SAME"
	+stringed
	!byte $aa, $aa, $55, $55, $aa, $aa, $55, $55, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES BLUE:SAME"
	+stringed
	!byte $33, $33, $66, $66, $33, $cc, $66, $99, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES LIGHT BLUE:SAME"
	+stringed
	!byte $bb, $bb, $77, $77, $bb, $ee, $77, $dd, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES DARK BROWN:SAME"
	+stringed
	!byte $44, $44, $88, $88, $44, $11, $88, $22, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES ORANGE:SAME"
	+stringed
	!byte $cc, $cc, $99, $99, $cc, $33, $99, $66, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES GRAY $A:SAME"
	+stringed
	!byte $55, $55, $aa, $aa, $55, $55, $aa, $aa, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES LIGHT MAGENTA:",$8D
	!text "SAME"
	+stringed
	!byte $dd, $dd, $bb, $bb, $dd, $77, $bb, $ee, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES GREEN:SAME"
	+stringed
	!byte $66, $66, $cc, $cc, $66, $99, $cc, $33, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES LIGHT BROWN:SAME"
	+stringed
	!byte $ee, $ee, $dd, $dd, $ee, $bb, $dd, $77, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off
	+string
	!text "DBL LORES AND DBL HIRES LIGHT BLUEGREEN:",$8D
	!text "SAME"
	+stringed
	!byte $77, $77, $ee, $ee, $77, $dd, $ee, $bb, .md_80col | .md_an3off, .md_hires | .md_80col | .md_an3off

	!byte $ff, $ff

} ;video

	!eof

	LORES $1
	DDDDDDD....... DDDDDDD.......
	10001000100010 00100010001000

	0010001
	0100010
	1000100
	0001000
