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

	;; print/printed prints the string between them.
	;;
	;; `+print` does a `jsr LASTSTRING`, jumping to the position
	;; of the next string, LASTSTRING, as if it were a
	;; subroutine. Then, setting the current address to
	;; LASTSTRING, it lays down a `jsr print`, so that first `jsr`
	;; will jump straight to another jump to `print`. That serves
	;; to get the address of the following string onto the stack.
	;;
	;; After that, you lay down the text you want to print, and a
	;; final `+printed` lays down a trailing zero byte and fixes
	;; up LASTSTRING ready for the next string, and puts the
	;; current position back after that `jsr` that started this
	;; dance.
	;;
	;; So, if you write:
	;;
	;; lda #42
	;; +print
	;; !text "HELLO, WORLD",$8D
	;; +printed
	;; sta $17
	;;
	;; what you get is this:
	;;
	;;
	;; lda #42
	;; jsr LASTSTRING(orig) ------------> LASTSTRING(orig): jsr print
	;; ; `print` returns here                               "HELLO, WORLD",$8D,$0
	;; sta $17                            LASTSTRING(new):  ; next string or jsr print goes here
	;;
	;;
	;; Why this dance? Well, the alternative would be either a
	;; version of `print` that expects the string directly after
	;; the `jsr` instruction in memory, or code that saves A, then
	;; pushes the HI and LO of LASTSTRING before calling `print`.
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

	;; +prerr/+prerred is like +print/+printed, but prints an
	;; error number and message.
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

	;; +prerra/+printed is a version of prerr that also displays
	;; the current value of A.
	!macro prerra NUM {
	ldy #>NUM
	ldx #<NUM
	jsr LASTSTRING
	!set TEMP = *
	* = LASTSTRING
	jsr errora
	}
