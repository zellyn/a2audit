;;; Apple II Printing of model and memory
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!zone detect {
	jsr IDENTIFY
	lda $C082		; Put ROM back in place.

	;; Fix up possibly broken MEMORY count on IIe machines.
	;; See UtAIIe: 5-38
	lda MACHINE
	cmp #IIe
	bne +++

	jsr RESETALL
	sta SET_80STORE
	lda SET_HIRES
	lda SET_PAGE2
	lda #$00
	sta $400
	lda #$88
	sta $2000
	cmp $400
	beq .has65k
	cmp $2000
	bne .has64k
	cmp $2000
	bne .has64k

	;; Okay, it looks like we have 128K. But what if our emulator
	;; is just broken, and we're reading and writing the same bank of
	;; RAM for both main and aux mem? Let's check for that explicitly.
	jsr RESETALL
	lda #$88
	sta $400
	lda #$89
	sta SET_RAMWRT
	sta $400
	lda #$88
	sta RESET_RAMWRT
	cmp $400
	bne +
	cmp $400
	beq ++

+	+prerr $000C ;; E000C: $400 main memory and $300 aux memory seem to write to the same place, which is probably an emulator bug.
	!text "BUG:MAIN AND AUX ARE SAME:PRETEND 64K"
	+prerred
	
.has64k
	lda #64
	!byte $2C
.has65k lda #65
	sta MEMORY

++	jsr RESETALL
	lda #'A'
	sta $400

+++	+print
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

;;; Error out if RAMRD or RAMWRT are set.
	lda $C013
	ora $C014
	bmi +
	jsr COPYTOAUX
	jmp .done

+	+prerr $0003 ;; E0003: Soft-switched for either RAMRD or RAMWRT read as set, which means we're either reading from, or writing to, auxiliary RAM. Please press RESET and run the test again to start in a known-good state.
	!text "RAMRD OR RAMWRT SET:RESET AND RERUN"
	+prerred
	jmp end
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
