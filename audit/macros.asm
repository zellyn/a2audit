;;; Apple II audit routine macros.
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	;; string/stringed drops a pointer to a string.
	!macro string {
	!word LASTSTRING
	!set TEMP = *
	* = LASTSTRING
	}
	!macro stringed {
	!byte 0
	!set LASTSTRING=*
	* = TEMP
	}

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
	ldy #>NUM
	ldx #<NUM
	jsr LASTSTRING
	!set TEMP = *
	* = LASTSTRING
	jsr error
	}
	!macro prerred {
	!byte $8D
	+printed
	}

	;; A version of prerr that also displays the current value of A.
	!macro prerra NUM {
	ldy #>NUM
	ldx #<NUM
	jsr LASTSTRING
	!set TEMP = *
	* = LASTSTRING
	jsr errora
	}
