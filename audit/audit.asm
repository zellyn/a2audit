;;; Apple II audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!convtab <apple ii/convtab.bin>
	!to "audit.o", plain
	* = $6000

	HOME = $FC58
	COUT = $FDED
	PRBYTE = $FDDA

	STRINGS = $7000
	!set LASTSTRING = $7000

	!macro print {
	lda #<LASTSTRING
	sta getch2+1
	lda #>LASTSTRING
	sta getch2+2
	jsr print2
	!set TEMP = *
	* = LASTSTRING
	}
	!macro printed {
	!byte 0
	!set LASTSTRING=*
	* = TEMP
	}

	!macro prerr NUM {
	+print
	}
	!macro prerred {
	!byte $8D
	+printed
	}
main:
	jsr HOME
	+print
	!text "APPLE II AUDIT",$8D,$8D
	+printed
	!zone detect {
	jsr IDENTIFY
	lda $C082		; Put ROM back in place.

	+print
	!text "MEMORY:"
	+printed
	lda MEMORY
	bpl +
	+print
	!text "128K",$8D
	+printed
	beq +++
+	cmp #64
	bcc +
	+print
	!text "64K",$8D
	+printed
	beq +++
+	+print
	!text "48K",$8D
	+printed
+++
	lda MACHINE
	bne .known
	;; MACHINE=0 - unknown machine
	+prerr $0001 ;; E0001: The machine identification routines from http://www.1000bit.it/support/manuali/apple/technotes/misc/tn.misc.02.html failed to identify the model.
	!text "UNABLE TO IDENTIFY"
	+prerred
	jmp end
.known
	cmp #IIeCard
	bcc .leiic
	bne .gs
;IIeCard
	+print
	!text "IIE EMULATION CARD"
	+printed
	beq .notsupported
.gs	;PLUGH
	+print
	!text "APPLE IIGS"
	+printed
.notsupported
	+prerr $0002 ;; E0002: The current version of the audit program doesn't support the identified machine.
	!text " NOT SUPPORTED"
	+prerred
	jmp end
.leiic
	cmp #IIe
	bcc .leiii
	beq .iie
;IIc
	+print
	!text "IIC"
	+printed
	beq .notsupported
.iie
	+print
	!text "APPLE IIE"
	+printed
	lda ROMLEVEL
	cmp #1
	beq +
	+print
	!text " (ENHANCED)"
	+printed
+	lda #$8D
	jsr COUT
	beq .done
.leiii
	cmp #IIplus
	bcc .iiplain
	beq .iiplus
;iiiem
	+print
	!text "APPLE III IN EMULATION MODE"
	+printed
	beq .notsupported
.iiplain
	+print
	!text "PLAIN APPLE II",$8D
	+printed
	beq .done
.iiplus	
	+print
	!text "APPLE II PLUS",$8D
	+printed
.done
	} ;detect

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
	
end:	jmp *

	!src "technote2.asm"

print2
	lda $C081
	lda $C081
getch2	lda $FEED
	beq +
	jsr COUT
	inc getch2+1
	bne getch2
	inc getch2+2
	jmp getch2
+	rts

;	!if * != STRINGS {
;	!error "Expected STRINGS to be ", *
;	}

	!if * > STRINGS {
	!error "End of compilation passed STRINGS:", *
	}
