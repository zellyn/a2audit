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
+	lda $C08B		; Read and write First 4K bank
	lda $C08B
	lda #$55
	sta $D17B		; D17B is $53 in Apple II/plus/e/enhanced
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
	beq .done
+	lda $C083		; Read and write Second 4K bank
	lda $C083
	lda #$AA
	sta $D17B
	cmp $D17B
	beq +
	+prerr $0005 ;; E0005: We tried to put the language card into read bank 2, write bank 2, but failed to write.
	!text "CANNOT WRITE TO LC BANK 2 RAM"
	+prerred
	beq .done
+	lda $C088		; RAM read, bank 1
	lda $D17B
	cmp #$55
	beq +++
	cmp #$AA
	bne +
	+prerr $0006 ;; E0006: Read $C088 (read bank 1), but the language card is still reading bank 2.
	!text "$C088: BANK 1 ACTIVE"
	+prerred
.done2	beq .done
+	cmp #$53
	bne +
	+prerr $0007 ;; E0007: Read $C088 (read bank 1), but the language card is reading ROM.
	!text "$C088: ROM ACTIVE"
	+prerred
	beq .done
+	+prerr $0007 ;; E0007: Read $C088 (read bank 1), but the check byte ($D17B) is an unknown value.
	!text "$C088: UNKNOWN BYTE"
	+prerred
	beq .done
+++	
	;; Test
	;; Success
	+print
	!text "LANGUAGE CARD TESTS SUCCEEDED",$8D
	+printed
.done
	} ;langcard
