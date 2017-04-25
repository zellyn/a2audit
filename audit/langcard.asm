;;; Apple II Language Card audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

!zone langcard {
	.checkdata = tmp1

LANGCARDTESTS
	lda #0
	sta LCRESULT
	lda MEMORY
	cmp #49
	bcs LANGCARDTESTS_NO_CHECK
	+print
	!text "48K:SKIPPING LANGUAGE CARD TEST",$8D
	+printed
	sec
	rts
LANGCARDTESTS_NO_CHECK:
	+print
	!text "TESTING LANGUAGE CARD",$8D
	+printed
	;; Setup - store differing values in bank first and second banked areas.
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$11
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	cmp $D17B
	beq +
	+prerr $0004 ;; E0004: We tried to put the language card into read bank 1, write bank 1, but failed to write.
	!text "CANNOT WRITE TO LC BANK 1 RAM"
	+prerred
	sec
	rts
+	lda #$33
	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	cmp $FE1F
	beq +
	+prerr $0005 ;; E0005: We tried to put the language card into read RAM, write RAM, but failed to write.
	!text "CANNOT WRITE TO LC RAM"
	+prerred
	sec
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
	sec
	rts
+	lda $C08B		; Read and write bank 1 with single access (only one needed if banked in already)
	lda #$11
	cmp $D17B
	beq +
	+prerr $000D ;; E000D: We tried to put the language card into read bank 1, but failed to read.
	!text "CANNOT READ FROM LC BANK 1 RAM"
	+prerred
	sec
	rts
+	lda $C081		; Read ROM with single access (only one needed to bank out)
	lda #$53
	cmp $D17B
	beq .datadriventests
	+prerr $000E ;; E000E: We tried to put the language card into read ROM, but failed to read.
	!text "CANNOT READ FROM ROM"
	+prerred
	sec
	rts

;;; Main data-driven test. PCL,PCH holds the address of the next
;;; data-driven test routine. We expect the various softswitches
;;; to be reset each time we loop at .ddloop.
.datadriventests
	lda #<.tests
	sta PCL
	lda #>.tests
	sta PCH
;;; Main data-drive-test loop.
.ddloop
	ldy #0

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

	jmp (PCL)		; Jump to test routine


	;; Test routine will JSR back to here, so the check data address is on the stack.

.test	;; ... test the quintiple of test values
	inc $D17B
	inc $FE1F

	;; pull address off of stack: it points just below check data for this test.
	pla
	sta .checkdata
	pla
	sta .checkdata+1

	;; .checkdata now points to d17b-current,fe1f-current,bank1,bank2,fe1f-ram test quintiple

	;; Test current $D17B
	jsr NEXTCHECK
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B TO CONTAIN $"
	+printed
	jsr CURCHECK
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	;; Test current $FE1F
	jsr NEXTCHECK
	cmp $FE1F
	beq +
	lda $FE1F
	pha
	jsr .printseq
	+print
	!text "$FE1F=$"
	+printed
	jsr CURCHECK
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	;; Test bank 1 $D17B
	lda $C088
	jsr NEXTCHECK
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B IN RAM BANK 1 TO CONTAIN $"
	+printed
	jsr CURCHECK
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	;; Test bank 2 $D17B
	lda $C080
	jsr NEXTCHECK
	cmp $D17B
	beq +
	lda $D17B
	pha
	jsr .printseq
	+print
	!text "$D17B IN RAM BANK 2 TO CONTAIN $"
	+printed
	jsr CURCHECK
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	;; Test RAM $FE1F
	lda $C080
	jsr NEXTCHECK
	cmp $FE1F
	beq +
	lda $FE1F
	pha
	jsr .printseq
	+print
	!text "RAM $FE1F=$"
	+printed
	jsr CURCHECK
	jsr PRBYTE
	+print
	!text ", GOT $"
	+printed
	pla
	jsr PRBYTE
	lda #$8D
	jsr COUT
	jmp .datatesturl

+	;; Jump PCL,PCH up to after the test data, and loop.
	jsr NEXTCHECK
	bne +
	jmp .success
+	ldx .checkdata
	ldy .checkdata+1
	stx PCL
	sty PCH
	jmp .ddloop

.datatesturl
	+prerr $0007 ;; E0007: This is a data-driven test of Language Card operation. We initialize $D17B in RAM bank 1 to $11, $D17B in RAM bank 2 to $22, and $FE1F in RAM to $33. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60. For more information on the operation of the language card soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-24.
	!text "DATA-DRIVEN TEST FAILED"
	+prerred
	sec
	rts

.printseq
	+print
	!text "AFTER SEQUENCE OF:",$8D,"- LDA   $C080",$8D
	+printed
	jsr PRINTTEST
	+print
	!text "- INC   $D17B",$8D,"- INC   $FE1F",$8D,"EXPECTED "
	+printed
	rts

.tests
	;; Format:
	;; Sequence of test instructions, finishing with `jsr .test`.
	;; - quint: expected current $d17b and fe1f, then d17b in bank1, d17b in bank 2, and fe1f
	;; (All sequences start with lda $C080, just to reset things to a known state.)
	;; 0-byte to terminate tests.

	lda $C088				; Read $C088 (RAM read, write protected)
	jsr .test				;
	!byte $11, $33, $11, $22, $33		;
						;
	lda $C080				; Read $C080 (read bank 2, write disabled)
	jsr .test				;
	!byte $22, $33, $11, $22, $33		;
						;
	lda $C081				; Read $C081 (ROM read, write disabled)
	jsr .test				;
	!byte $53, $60, $11, $22, $33		;
						;
	lda $C081				; Read $C081, $C089 (ROM read, bank 1 write)
	lda $C089				;
	jsr .test				;
	!byte $53, $60, $54, $22, $61		;
						;
	lda $C081				; Read $C081, $C081 (read ROM, write RAM bank 2)
	lda $C081				;
	jsr .test				;
	!byte $53, $60, $11, $54, $61		;
						;
	lda $C081				; Read $C081, $C081, write $C081 (read ROM, write RAM bank bank 2)
	lda $C081				;
	sta $C081				;
	jsr .test				;
	!byte $53, $60, $11, $54, $61		; See https://github.com/zellyn/a2audit/issues/3
						;
	lda $C08B				; Read $C08B (read RAM bank 1, no write)
	jsr .test				;
	!byte $11, $33, $11, $22, $33		;
						;
	lda $C083				; Read $C083 (read RAM bank 2, no write)
	jsr .test				;
	!byte $22, $33, $11, $22, $33		;
						;
	lda $C08B				; Read $C08B, $C08B (read/write RAM bank 1)
	lda $C08B				;
	jsr .test				;
	!byte $12, $34, $12, $22, $34		;
						;
	lda $C08F				; Read $C08F, $C087 (read/write RAM bank 2)
	lda $C087				;
	jsr .test				;
	!byte $23, $34, $11, $23, $34		;
						;
	lda $C087				; Read $C087, read $C08D (read ROM, write bank 1)
	lda $C08D				;
	jsr .test				;
	!byte $53, $60, $54, $22, $61		;
						;
	lda $C08B				; Read $C08B, write $C08B, read $C08B (read RAM bank 1, no write)
	sta $C08B				; (this one is tricky: reset WRTCOUNT by writing halfway)
	lda $C08B				;
	jsr .test				;
	!byte $11, $33, $11, $22, $33		;
						;
	sta $C08B				; Write $C08B, write $C08B, read $C08B (read RAM bank 1, no write)
	sta $C08B				;
	lda $C08B				;
	jsr .test				;
	!byte $11, $33, $11, $22, $33		;
						;
	!byte 0

	nop			; Provide clean break after data when viewing disassembly
	nop
.success

	;; Success
	+print
	!text "LANGUAGE CARD TESTS SUCCEEDED",$8D
	+printed
	lda #1
	sta LCRESULT
	clc
	rts
} ;langcard
