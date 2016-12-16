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

	;; Printing and error macros.
	!src "macros.asm"
	
main:
	jsr HOME
	+print
	!text "APPLE II AUDIT",$8D,$8D
	+printed

	;; Detection and reporting of model and memory.
	!src "detect.asm"

	;; Language card tests.
	!src "langcard.asm"
	
end:	jmp *

print
	lda $C081
	lda $C081
	pla
	sta getch+1
	pla
	sta getch+2
-	inc getch+1
	bne getch
	inc getch+2
getch	lda $FEED		; FEED gets modified
	beq +
	jsr COUT
	jmp -
+	rts
	
	!src "technote2.asm"

;	!if * != STRINGS {
;	!error "Expected STRINGS to be ", *
;	}

	!if * > STRINGS {
	!error "End of compilation passed STRINGS:", *
	}

