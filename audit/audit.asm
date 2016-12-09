;;; Apple II audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!convtab <apple ii/convtab.bin>
	!to "audit.o", plain
	* = $6000

	HOME = $FC58
	COUT = $FDED
	PRBYTE = $FDDA

main:
	jsr HOME
	jsr print
	!text "APPLE II AUDIT",$8D,0
	jsr print
	!text "DETECTING MACHINE VERSION...",$8D,0

	!zone detect {
	jsr IDENTIFY
	lda $C082		; Put ROM back in place.
	lda MACHINE
	jsr PRBYTE
	lda #$8D
	jsr COUT
	lda MACHINE
	bne .known
	;; MACHINE=0 - unknown machine
	jsr print
	!text "UNABLE TO IDENTIFY",$8D,0
	jmp end
.known
	cmp #IIeCard
	bcc .leiic
	bne .gs
;IIeCard
	jsr print
	!text "IIE EMULATION CARD",0
	beq .notsupported
.gs	;PLUGH
	jsr print
	!text "IIGS",0
.notsupported
	jsr print
	!text " NOT SUPPORTED",$8D,0
	jmp end
.leiic
	cmp #IIe
	bcc .leiii
	beq .iie
;IIc
	jsr print
	!text "IIC",0
	beq .notsupported
.iie
	jsr print
	!text "APPLE IIE",$8D,0
	beq .done
.leiii
	cmp #IIplus
	bcc .iiplain
	beq .iiplus
;iiiem
	jsr print
	!text "APPLE III IN EMULATION MODE",0
	beq .notsupported
.iiplain
	jsr print
	!text "PLAIN APPLE II",$8D,0
	beq .done
.iiplus	
	jsr print
	!text "APPLE II PLUS",$8D,0
.done
	} ;detect
	
end:	jmp *

;;; print prints a null-terminated string from the address after the
;;; JSR that called it, returning to the address following the null.
print:
	pla
	sta getch+1
	pla
	sta getch+2
-	inc getch+1
	bne getch
	inc getch+2
getch	lda $FEED 		; $FEED gets modified
	beq +
	jsr COUT
	jmp -
+	lda getch+2
	pha
	lda getch+1
	pha
	lda #0			; so we can always beq after print-ing
	rts

	!src "technote2.asm"
