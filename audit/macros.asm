;;; Apple II audit routine macros.
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!macro print {
	jsr LASTSTRING
	!set TEMP = *
	* = LASTSTRING
	jsr print
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
