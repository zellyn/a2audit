;;; Apple II Language Card audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!zone langcard {
LANGCARDTESTS
	lda MEMORY
	cmp #49
	bcs +
	+print
	!text "48K:SKIPPING LANGUAGE CARD TEST",$8D
	+printed
	rts
	;; Setup - store differing values in bank first and second banked areas.
+	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$11
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	cmp $D17B
	beq +
	+prerr $0004 ;; E0004: We tried to put the language card into read bank 1, write bank 1, but failed to write.
	!text "CANNOT WRITE TO LC BANK 1 RAM"
	+prerred
	rts
	lda #$33
+	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	cmp $FE1F
	beq .dotest
	+prerr $0005 ;; E0005: We tried to put the language card into read RAM, write RAM, but failed to write.
	!text "CANNOT WRITE TO LC RAM"
	+prerred
	rts
+	lda $C083		; Read and write bank 2
	lda $C083
	lda #$22
	sta $D17B
	cmp $D17B
	beq +
	+prerr $0006 ;; E0006: We tried to put the language card into read bank 2, write bank 2, but failed to write.
	!text "CANNOT WRITE TO LC BANK 2 RAM"
	+prerred
	rts

	;; Parameterized tests

.dotest	lda #<.tests
	sta 0
	lda #>.tests
	sta 1
.outer
	;; Initialize to known state:
	;; - $11 in $D17B bank 1 (ROM: $53)
	;; - $22 in $D17B bank 2 (ROM: $53)
	;; - $33 in $FE1F        (ROM: $60)
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$11
	sta $D17B
	lda #$33
	sta $FE1F
	lda $C083		; Read and write bank 2
	lda $C083
	lda #$22
	sta $D17B
	lda $C080

	ldy #0

.inner
	lda ($0),y
	cmp #$ff
	beq .test
	tax
	bmi +
	ora #$80
	sta .lda+1
.lda	lda $C000
	jmp ++
+	sta .sta+1
.sta	sta $C000
++	iny
	bne .inner

.test	;; ... test the triple
	inc $D17B
	inc $FE1F
	iny

	;; y now points to d17b-current,fe1f-current,bank1,bank2,fe1f-ram test quintiple

	;; Test current $D17B
	lda (0),y
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B TO CONTAIN $"
	+printed
	lda (0),y
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	iny
	;; Test current $FE1F
	lda (0),y
	cmp $FE1F
	beq +
	lda $FE1F
	pha
	jsr .printseq
	+print
	!text "$FE1F=$"
	+printed
	lda (0),y
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	iny

	;; Test bank 1 $D17B
	lda $C088
	lda (0),y
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B IN RAM BANK 1 TO CONTAIN $"
	+printed
	lda (0),y
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	iny

	;; Test bank 2 $D17B
	lda $C080
	lda (0),y
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B IN RAM BANK 2 TO CONTAIN $"
	+printed
	lda (0),y
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	iny

	;; Test RAM $FE1F
	lda $C080
	lda (0),y
	cmp $FE1F
	beq +
	lda $FE1F
	pha
	jsr .printseq
	+print
	!text "RAM $FE1F=$"
	+printed
	lda (0),y
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	iny

	lda ($0),y		; Done with the parameterized tests?
	cmp #$ff
	bne +
	jmp .over
+	clc
	tya
	adc $0
	sta $0
	bcc +
	inc $1
+	jmp .outer

.datatesturl
	+prerr $0007 ;; E0007: This is a data-driven test of Language Card operation. We initialize $D17B in RAM bank 1 to $11, $D17B in RAM bank 2 to $22, and $FE1F in RAM to $33. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60. For more information on the operation of the language card soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-24.
	!text "DATA-DRIVEN TEST FAILED"
	+prerred
	rts

.printseq
	tya
	pha
	+print
	!text "AFTER SEQUENCE OF:",$8D,"LDA $C080",$8D
	+printed
	ldy #$0
-	lda ($0),y
	cmp #$ff
	beq +++
	tax
	bmi +
	lda #'L'
	jsr COUT
	lda #'D'
	bne ++
+	lda #'S'
	jsr COUT
	lda #'T'
++	jsr COUT
	+print
	!text "A $C0"
	+printed
	txa
	ora #$80
	jsr PRBYTE
	lda #$8D
	jsr COUT
	iny
	bne -
+++
	+print
	!text "INC $D17B",$8D,"INC $FE1F",$8D,"EXPECTED "
	+printed
	pla
	tay
	rts

.tests
	;; Format:
	;; - $ff-terminated list of C0XX addresses (0-F to read C08X, 80-8F to write C0XX).
	;; - quint: expected current $d17b and fe1f, then d17b in bank1, d17b in bank 2, and fe1f
	;; (All sequences start with lda $C080, just to reset things to a known state.)
	!byte $08, $ff				; Read $C088 (RAM read, write protected)
	!byte $11, $33, $11, $22, $33		;
	!byte $00, $ff				; Read $C080 (read bank 2, write disabled)
	!byte $22, $33, $11, $22, $33		;
	!byte $01, $ff				; Read $C081 (ROM read, write disabled)
	!byte $53, $60, $11, $22, $33		;
	!byte $01, $09, $ff			; Read $C081, $C089 (ROM read, bank 1 write)
	!byte $53, $60, $54, $22, $61		;
	!byte $01, $01, $ff			; Read $C081, $C081 (read ROM, write RAM bank 2)
	!byte $53, $60, $11, $54, $61		;
	!byte $0b, $ff				; Read $C08B (read RAM bank 1, no write)
	!byte $11, $33, $11, $22, $33		;
	!byte $03, $ff				; Read $C083 (read RAM bank 2, no write)
	!byte $22, $33, $11, $22, $33		;
	!byte $0b, $0b, $ff			; Read $C08B, $C08B (read/write RAM bank 1)
	!byte $12, $34, $12, $22, $34		;
	!byte $0f, $07, $ff			; Read $C08F, $C087 (read/write RAM bank 2)
	!byte $23, $34, $11, $23, $34		;
	!byte $07, $0D, $ff			; Read $C087, read $C08D (read ROM, write bank 1)
	!byte $53, $60, $54, $22, $61		;
	!byte $0b, $8b, $0b, $ff		; Read $C08B, write $C08B, read $C08B (read RAM bank 1, no write)
	!byte $11, $33, $11, $22, $33		; (this one is tricky: reset WRTCOUNT by writing halfway)
	!byte $ff

	nop			; Provide clean break after data when viewing disassembly
	nop
	nop
.over

	;; Success
	+print
	!text "LANGUAGE CARD TESTS SUCCEEDED",$8D
	+printed
.done
	rts
	} ;langcard
