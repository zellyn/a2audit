	!to "shasum.o", plain
	* = $6000
	jmp main

	!addr	SRC = $06
	!addr	DST = $08
	!addr   SHAINPUT = $eb
	!addr   SHALENGTH = $ee

	!addr PRBYTE = $FDDA
	!addr COUT = $FDED

	
	!macro set32 .target, .value {
	lda #<(.value >> 24)
	sta .target
	lda #<(.value >> 16)
	sta .target+1
	lda #<(.value >> 8)
	sta .target+2
	lda #<(.value)
	sta .target+3
	}

	!macro setSRC .source {
	lda #<.source
	sta SRC
	lda #>.source
	sta SRC+1
	}
	!macro setDST .dest {
	lda #<.dest
	sta DST
	lda #>.dest
	sta DST+1
	}

;;; Print a string of bytes, as hex.
;;; Address in SRC, count in A.
;;; Burns A,Y.
prbytes:
	ldy #0
-	pha
	lda (SRC),y
	jsr PRBYTE
	iny
	pla
	adc #$ff
	bne -
	rts

main:
	;; Test shasum ""
	lda #0
	sta SHAINPUT
	lda #$fe
	sta SHAINPUT+1
	lda #0
	sta SHALENGTH+1
	lda #0			; da39a3ee5e6b4b0d3255bfef95601890afd80709
	sta SHALENGTH
	jsr SHASUM

	; lda #$8d
	; jsr COUT

	+setSRC SHA
	lda #SHALEN
	jsr prbytes

	;; Test shasum FE00[:0x37]
	lda #0
	sta SHAINPUT
	lda #$fe
	sta SHAINPUT+1
	lda #0
	sta SHALENGTH+1
	lda #$37		; 1CF73FC6156B548A949D315120B5256245EAA33E
	sta SHALENGTH
	jsr SHASUM

	; lda #$8d
	; jsr COUT

	+setSRC SHA
	lda #SHALEN
	jsr prbytes
	
	;; Test shasum FE00[:0x100]
	lda #0
	sta SHAINPUT
	lda #$fe
	sta SHAINPUT+1
	lda #1
	sta SHALENGTH+1
	lda #0		; 7B3D05347B52210065E27054FDFD0B8B699F0965
	sta SHALENGTH
	jsr SHASUM

	; lda #$8d
	; jsr COUT

	+setSRC SHA
	lda #SHALEN
	jsr prbytes
	
	;; Test shasum FE00[:0x1ff]
	lda #0
	sta SHAINPUT
	lda #$fe
	sta SHAINPUT+1
	lda #$1
	sta SHALENGTH+1
	lda #$ff		; 269CA6B0C644DAC01D908B20C10C0D5B19C52ABF
	sta SHALENGTH
	jsr SHASUM

	; lda #$8d
	; jsr COUT

	+setSRC SHA
	lda #SHALEN
	jsr prbytes
	
	;; Test shasum FE00[:0x200]
	lda #0
	sta SHAINPUT
	lda #$fe
	sta SHAINPUT+1
	lda #2
	sta SHALENGTH+1
	lda #0		; D5AC71D5EE76E31CC82CF5136151BF4CDA503601
	sta SHALENGTH
	jsr SHASUM

	; lda #$8d
	; jsr COUT

	+setSRC SHA
	lda #SHALEN
	jsr prbytes
	
	rts

	!src "shasum.asm"
