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
	beq .done2
+	lda $C083		; Read and write Second 4K bank
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
	
+	lda $C088		; RAM read, bank 1
	lda $D17B
	cmp #$55
	beq ++
	cmp #$AA
	bne +
	+prerr $0006 ;; E0006: Read $C088 (read bank 1), but the language card is still reading bank 2.
	!text "$C088: BANK 2 ACTIVE"
	+prerred
.done2	beq .done3
+	cmp #$53
	bne +
	+prerr $0007 ;; E0007: Read $C088 (read bank 1), but the language card is reading ROM.
	!text "$C088: ROM ACTIVE"
	+prerred
	beq .done3
+	+prerr $0007 ;; E0007: Read $C088 (read bank 1), but the check byte ($D17B) is an unknown value.
	!text "$C088: UNKNOWN BYTE"
	+prerred
	beq .done3
++	dec $D17B
	eor $D17B
	beq +
	+prerr $0008 ;; E0008: Read $C088 (read bank 1, write-protected), but successfully wrote byte ($D17B).
	!text "$C088: ALLOWED WRITE"
	+prerred
	beq .done3

+	lda $C080		; RAM read, bank 2
	lda $D17B
	cmp #$AA
	beq ++
	cmp #$55
	bne +
	+prerr $0009 ;; E0009: Read $C080 (read bank 2), but the language card is still reading bank 1.
	!text "$C080: BANK 1 ACTIVE"
	+prerred
	beq .done3
+	cmp #$53
	bne +
	+prerr $000A ;; E000A: Read $C080 (read bank 2), but the language card is reading ROM.
	!text "$C080: ROM ACTIVE"
	+prerred
	beq .done3
+	+prerr $000B ;; E000B: Read $C080 (read bank 2), but the check byte ($D17B) is an unknown value.
	!text "$C080: UNKNOWN BYTE"
	+prerred
.done3	beq .done
++	dec $D17B
	eor $D17B
	beq +
	+prerr $000C ;; E000C: Read $C080 (read bank 2, write-protected), but successfully wrote byte ($D17B).
	!text "$C080: ALLOWED WRITE"
	+prerred
	beq .done

+	lda $C081		; ROM read
	lda $D17B
	cmp #$53
	beq ++
	cmp #$55
	bne +
	+prerr $000D ;; E000D: Read $C081 (read ROM), but the language card is still reading bank 1.
	!text "$C081: BANK 1 ACTIVE"
	+prerred
	beq .done
+	cmp #$AA
	bne +
	+prerr $000E ;; E000E: Read $C081 (read ROM), but the language card is reading bank 2.
	!text "$C081: BANK 1 ACTIVE"
	+prerred
	beq .done
+	+prerr $000F ;; E000F: Read $C081 (read ROM), but the check byte ($D17B) is an unknown value.
	!text "$C081: UNKNOWN BYTE"
	+prerred
	beq .done
++	dec $D17B
	eor $D17B
	beq +
	+prerr $0010 ;; E0010: Read $C081 (read ROM), but successfully modified byte ($D17B).
	!text "$C081: ALLOWED WRITE"
	+prerred
	beq .done

+	

	;; Success
	+print
	!text "LANGUAGE CARD TESTS SUCCEEDED",$8D
	+printed
.done
	} ;langcard
