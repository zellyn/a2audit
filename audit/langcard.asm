;;; Apple II Language Card audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!zone langcard {

	lda MEMORY
	cmp #49
	bcs +
	+print
	!text "48K:SKIPPING LANGUAGE CARD TEST",$8D
	+printed
	beq .done2
	;; Setup - store differing values in bank first and second banked areas.
+	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$55
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	cmp $D17B
	beq +
	+prerr $0003 ;; E0003: We tried to put the language card into read bank 1, write bank 1, but failed to write.
	!text "CANNOT WRITE TO LC BANK 1 RAM"
	+prerred
	beq .done2
+	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	cmp $FE1F
	beq +
	+prerr $0004 ;; E0004: We tried to put the language card into read RAM, write RAM, but failed to write.
	!text "CANNOT WRITE TO LC RAM"
	+prerred
	beq .done2
+	lda $C083		; Read and write bank 2
	lda $C083
	lda #$AA
	sta $D17B
	cmp $D17B
	beq +
	+prerr $0005 ;; E0005: We tried to put the language card into read bank 2, write bank 2, but failed to write.
	!text "CANNOT WRITE TO LC BANK 2 RAM"
	+prerred
	beq .done2

	;; Test that we're reading the right things
	
+	lda $C088		; RAM read, bank 1, write disabled
	lda $D17B
	cmp #$55
	beq ++
	cmp #$AA
	bne +
	+prerr $0006 ;; E0006: Read $C088 (read bank 1), but the language card is still reading bank 2.
	!text "$C088: BANK 2 ACTIVE"
	+prerred
	beq .done2
+	cmp #$53
	bne +
	+prerr $0007 ;; E0007: Read $C088 (read bank 1), but the language card is reading ROM.
	!text "$C088: ROM ACTIVE"
	+prerred
	beq .done2
+	+prerra $0008 ;; E0008: Read $C088 (read bank 1), but the check byte ($D17B) is an unknown value.
	!text "$C088: UNKNOWN BYTE"
	+prerred
	beq .done2
++	inc $D17B
	eor $D17B
	beq +
	+prerr $0009 ;; E0009: Read $C088 (read bank 1, write-protected), but successfully wrote byte ($D17B).
	!text "$C088: ALLOWED WRITE"
	+prerred
.done2	beq .done3

+	lda $C080		; RAM read, bank 2, write disabled
	lda $D17B
	cmp #$AA
	beq ++
	cmp #$55
	bne +
	+prerr $000A ;; E000A: Read $C080 (read bank 2), but the language card is still reading bank 1.
	!text "$C080: BANK 1 ACTIVE"
	+prerred
	beq .done3
+	cmp #$53
	bne +
	+prerr $000B ;; E000B: Read $C080 (read bank 2), but the language card is reading ROM.
	!text "$C080: ROM ACTIVE"
	+prerred
	beq .done3
+	+prerra $000C ;; E000C: Read $C080 (read bank 2), but the check byte ($D17B) is an unknown value.
	!text "$C080: UNKNOWN BYTE"
	+prerred
	beq .done3
++	inc $D17B
	eor $D17B
	beq +
	+prerr $000D ;; E000D: Read $C080 (read bank 2, write-protected), but successfully wrote byte ($D17B).
	!text "$C080: ALLOWED WRITE"
	+prerred
	beq .done3

+	lda $C081		; ROM read, bank 2 no write
	lda $D17B
	cmp #$53
	beq ++
	cmp #$55
	bne +
	+prerr $000E ;; E000E: Read $C081 (read ROM), but the language card is still reading bank 1.
	!text "$C081: BANK 1 ACTIVE"
	+prerred
	beq .done3
+	cmp #$AA
	bne +
	+prerr $000F ;; E000F: Read $C081 (read ROM), but the language card is reading bank 2.
	!text "$C081: BANK 1 ACTIVE"
	+prerred
	beq .done3
+	+prerra $0010 ;; E0010: Read $C081 (read ROM), but the check byte ($D17B) is an unknown value.
	!text "$C081: UNKNOWN BYTE"
	+prerred
	beq .done3
++	dec $D17B
	eor $D17B
	beq +
	+prerr $0011 ;; E0011: Read $C081 (read ROM), but successfully modified byte ($D17B).
	!text "$C081: ALLOWED WRITE"
	+prerred
.done3	beq .done4

+	lda $C089		; ROM read, bank 1 write
	lda $D17B
	cmp #$53
	beq ++
	cmp #$55
	bne +
	+prerr $0012 ;; E0012: Read $C089 (read ROM), but the language card is still reading bank 1.
	!text "$C089: BANK 1 ACTIVE"
	+prerred
	beq .done4
+	cmp #$AA
	bne +
	+prerr $0013 ;; E0013: Read $C089 (read ROM), but the language card is reading bank 2.
	!text "$C089: BANK 1 ACTIVE"
	+prerred
	beq .done4
+	+prerra $0014 ;; E0014: Read $C089 (read ROM), but the check byte ($D17B) is an unknown value.
	!text "$C089: UNKNOWN BYTE"
	+prerred
	beq .done4
++	inc $D17B		; bank 1 now holds $54 instead of $55
	eor $D17B
	beq +
	+prerr $0015 ;; E0015: Read $C089 (read ROM), but successfully modified byte ($D17B).
	!text "$C089: ALLOWED WRITE"
	+prerred
	beq .done4

+	lda $C08B		; RAM read, bank 1
	lda $D17B
	cmp #$54
	beq ++
	cmp #$AA
	bne +
	+prerr $0016 ;; E0016: Read $C08B (read bank 1), but the language card is still reading bank 2.
	!text "$C08B: BANK 2 ACTIVE"
	+prerred
	beq .done4
+	cmp #$53
	bne +
	+prerr $0017 ;; E0017: Read $C08B (read bank 1), but the language card is reading ROM.
	!text "$C08B: ROM ACTIVE"
	+prerred
	beq .done4
+	cmp #$55
	bne +
	+prerr $0018 ;; E0018: Read $C08B (read bank 1); byte should have been previously incremented from ROM ($53) to $54 because of lda $C089 after previous lda $C081.
	!text "$C08B: PREVIOUS WRITE FAILED"
	+prerred
	beq .done4
+	+prerra $0019 ;; E0019: Read $C08B (read bank 1), but the check byte ($D17B) is an unknown value.
	!text "$C08B: UNKNOWN BYTE"
	+prerred
.done4	beq .done5
++

+	lda $C083		; RAM read, bank 2
	lda $D17B
	cmp #$AA
	beq ++
	cmp #$54
	bne +
	+prerr $001A ;; E001A: Read $C083 (read bank 2), but the language card is still reading bank 1.
	!text "$C083: BANK 1 ACTIVE"
	+prerred
	beq .done5
+	cmp #$53
	bne +
	+prerr $001B ;; E001B: Read $C083 (read bank 2), but the language card is reading ROM.
	!text "$C083: ROM ACTIVE"
	+prerred
	beq .done5
+	cmp #$52
	bne +
	+prerr $001C ;; E001C: Read $C083 (read bank 2); byte should have been previously NOT been writable to be decremented from ROM ($53) to $52 because of single lda $C081 after previous lda $C080.
	!text "$C083: PREVIOUS WRITE SUCCEEDED"
	+prerred
	beq .done5
+	+prerra $001D ;; E001D: Read $C083 (read bank 2), but the check byte ($D17B) is an unknown value.
	!text "$C083: UNKNOWN BYTE"
	+prerred
.done5	jmp .done
++
	;; Parameterized tests

	lda #<.tests
	sta 0
	lda #>.tests
	sta 1
.outer
	;; Initialize to known state:
	;; - $55 in $D17B bank 1 (ROM: $53)
	;; - $AA in $D17B bank 2 (ROM: $53)
	;; - $55 in $FE1F        (ROM: $60)
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$55
	sta $D17B
	sta $FE1F
	lda $C083		; Read and write bank 2
	lda $C083
	lda #$AA
	sta $D17B
	lda $C080

	ldy #0

.inner
	lda ($0),y
	cmp #$ff
	beq .test
	tax
	bmi +
	lda $C080,x
	jmp ++
+	sta $C000,x
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
	beq .over
	clc
	tya
	adc $0
	sta $0
	bcc +
	inc $1
+	jmp .outer

.datatesturl
	+prerr $001E ;; E001E: We initialized $D17B in RAM bank 1 to $55, $D17B in RAM bank 2 to $AA, and $FE1F in RAM to $55. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60.
	!text "DATA-DRIVEN TEST FAILED"
	+prerred
	beq .done
	
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
	!byte $8, $ff		; Read $C088 (RAM read, write protected)
	!byte $55, $55, $55, $AA, $54
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
	} ;langcard
