;;; Apple II audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!convtab <apple ii/convtab.bin>
	!to "audit.o", plain
	* = $6000

	HOME = $FC58
	COUT = $FDED

main:
	jsr HOME
	jsr print
	!text "Apple II audit",$8D,0
	jsr print
	!text "Detecting machine version...",$8D,0
end:	jmp *

;;; print prints a null-terminated string from the address after the
;;; JSR that called it, returning to the address following the null.
print:
	tsx
	lda $101,X
	sta getch+1
	lda $102,X
	sta getch+2
-	inc getch+1
	bne getch
	inc getch+2
getch	lda $FEED 		; $FEED gets modified
	beq +
	jsr COUT
	jmp -
+	lda getch+1
	sta $101,X
	lda getch+2
	sta $102,x
	rts
