;;; Apple II Printing of model and memory
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

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

	!src "technote2.asm"
