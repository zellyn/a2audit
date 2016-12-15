;;; Apple II audit routine macros.
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

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
