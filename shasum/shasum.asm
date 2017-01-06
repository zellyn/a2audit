;;; SHA-1 implementation in 6502 assembly.
;;; A straightforward implementation of:
;;; https://en.wikipedia.org/wiki/SHA-1#SHA-1_pseudocode
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!zone shasum {

	;; clear addresses:
	;; (http://apple2.org.za/gswv/a2zine/faqs/csa2pfaq.html#017)
	;; 06-09
	;; EB-EF
	;; FA-FD

	!addr	SRC = $06
	!addr	DST = $08
	!addr   SHAINPUT = $eb
	!addr   SHALENGTH = $ee
	!addr   .tmp1 = $fa
	!addr   .tmp2 = $fb

	!addr PRBYTE = $FDDA
	!addr COUT = $FDED

	!macro .set32 .target, .value {
	lda #<(.value >> 24)
	sta .target
	lda #<(.value >> 16)
	sta .target+1
	lda #<(.value >> 8)
	sta .target+2
	lda #<(.value)
	sta .target+3
	}

	!macro .setSRC .source {
	lda #<.source
	sta SRC
	lda #>.source
	sta SRC+1
	}
	!macro .setDST .dest {
	lda #<.dest
	sta DST
	lda #>.dest
	sta DST+1
	}


	!align 255, 0		; align data area to page boundary
SHA:
SHALEN = 20
.h0:	!32 0			; return value (hash)
.h1:	!32 0
.h2:	!32 0
.h3:	!32 0
.h4:	!32 0
.h5:
.ml:	!32 0, 0		; message length
.w:	!fill 64, 0
.w_next:	!fill 64, 0
.a:	!32 0
.b:	!32 0
.c:	!32 0
.d:	!32 0
.e:	!32 0
.f:	!32 0
.temp:	!32 0
.k:	!32 0
.kh0:	!be32 $67452301		; initial values for h0..h4
.kh1:	!be32 $EFCDAB89
.kh2:	!be32 $98BADCFE
.kh3:	!be32 $10325476
.kh4:	!be32 $C3D2E1F0
.k1 = $5A827999		; k constants
.k2 = $6ED9EBA1
.k3 = $8F1BBCDC
.k4 = $CA62C1D6

SHASUM:
	;; Initialize h0..h4
	ldy #(.h5-.h0-1)
-	lda .kh0,y
	sta .h0,y
	dey
	bpl -
	;; Initialize message length (.ml)
	lda #0
	ldy #4
-	sta .ml, y
	dey
	bpl -
	lda SHALENGTH
	sta .ml+7
	lda SHALENGTH+1
	sta .ml+6

	;; Message length is in bits
	ldy #3
-	asl .ml+7
	rol .ml+6
	rol .ml+5
	dey
	bne -

	;; Initialize chunk counter
	;; ldy #0			; already zero

	;; Invert length so we can inc instead of dec
	lda SHALENGTH
	sec
	lda #0
	sbc SHALENGTH
	sta SHALENGTH
	lda #0
	sbc SHALENGTH+1
	sta SHALENGTH+1
	ora SHALENGTH
	beq .msgdone

.loop	lda (SHAINPUT),y
	sta .w,y
	iny
	cpy #$40
	bne +

	;; Call do_chunk
	jsr do_chunk
	ldy #0

	clc
	lda SHAINPUT
	adc #$40
	sta SHAINPUT
	bcc +
	inc SHAINPUT+1

+	inc SHALENGTH
	bne .loop
	inc SHALENGTH+1
	bne .loop

.msgdone:
	lda #$80
	sta .w,y
	iny
	cpy #$40
	bne .zeros
	jsr do_chunk
	ldy #0

.zeros
	cpy #$38
	beq .length
	lda #0
	sta .w,y
	iny
	cpy #$40
	bne .zeros
	jsr do_chunk
	ldy #0
	jmp .zeros
.length
	ldy #7
-	lda .ml,y
	sta .w+$38,y
	dey
	bpl -
	jsr do_chunk
	rts

;;; do_chunk processes a chunk of input. It burns A,X,Y,.tmp1,.tmp2.
do_chunk:
	;; Copy a..e from h0..h4

	ldy #(.f-.a-1)
-	lda .h0,y
	sta .a,y
	dey
	bpl -

	ldy #0			; y is index into w

	;; First 20: k1
	+.set32 .k, .k1

	ldx #16
-	jsr kind1
	dex
	bne -
	jsr fill
	ldx #4
-	jsr kind1
	dex
	bne -
	;; Second 20: k2
	+.set32 .k, .k2

	ldx #12
-	jsr kind2
	dex
	bne -
	jsr fill
	ldx #8
-	jsr kind2
	dex
	bne -

	;; Third 20: k3
	+.set32 .k, .k3

	ldx #8
-	jsr kind3
	dex
	bne -
	jsr fill
	ldx #12
-	jsr kind3
	dex
	bne -

	;; Fourth 20: k4
	+.set32 .k, .k4

	ldx #4
-	jsr kind2
	dex
	bne -
	jsr fill
	ldx #16
-	jsr kind2
	dex
	bne -

	+.setSRC .a
	+.setDST .h0
	ldx #5
-	jsr add32
	clc
	lda SRC
	adc #4
	sta SRC
	lda DST
	adc #4
	sta DST
	dex
	bne -
	rts

kind1:
	sty .tmp1
	stx .tmp2
	;; f = d xor (b and (c xor d))
	+.setDST .f
	+.setSRC .d
	jsr cp32
	+.setSRC .c
	jsr xor32
	+.setSRC .b
	jsr and32
	+.setSRC .d
	jsr xor32

	jmp common
kind2:
	sty .tmp1
	stx .tmp2
	;; f = b xor c xor d
	+.setDST .f
	+.setSRC .d
	jsr cp32
	+.setSRC .c
	jsr xor32
	+.setSRC .b
	jsr xor32

	jmp common
kind3:
	sty .tmp1
	stx .tmp2
	;; f = (b and c) or (d and (b or c))
	+.setSRC .c
	+.setDST .f
	jsr cp32
	+.setDST .temp
	jsr cp32
	+.setSRC .b
	jsr and32
	+.setDST .f
	jsr or32
	+.setSRC .d
	jsr and32
	+.setSRC .temp
	jsr or32
	; jmp common

common:

        ;; temp = (a leftrotate 5) + f + e + k + w[i]
	+.setDST .temp
	+.setSRC .a
	jsr cp32
	jsr rol8

	jsr ror1
	jsr ror1
	jsr ror1

	+.setSRC .f
	jsr add32
	+.setSRC .e
	jsr add32
	+.setSRC .k
	jsr add32

	;; !.setSRC w[i], and call add32
	ldy .tmp1
	clc
	tya
	adc #<.w
	sta SRC
	lda #0
	adc #>.w
	sta SRC+1
	jsr add32

        ;; e = d
	+.setSRC .d
	+.setDST .e
	jsr cp32

        ;; d = c
	+.setSRC .c
	+.setDST .d
	jsr cp32

        ;; c = b leftrotate 30
	+.setSRC .b
	+.setDST .c
	jsr cp32
	jsr ror1
	jsr ror1

        ;; b = a
	+.setSRC .a
	+.setDST .b
	jsr cp32

        ;; a = temp
	+.setSRC .temp
	+.setDST .a
	jsr cp32

	ldy .tmp1
	ldx .tmp2
	iny
	iny
	iny
	iny
	rts

	;; Replace w[i:i+16] with w[i+16:i+32]. Burns a. Sets y=0.
fill:
	+.setDST .w_next
	+.setSRC .w
	ldx #0x10

-	sec
	lda DST
	sbc #16*4
	sta SRC
	jsr cp32		; w[i] = w[i-16]
	clc
	lda SRC
	adc #2*4
	sta SRC
	jsr xor32		;      ^ w[i-14]
	lda SRC
	adc #6*4
	sta SRC
	jsr xor32		;      ^ w[i-8]
	lda SRC
	adc #5*4
	sta SRC
	jsr xor32		;      ^ w[i-3]
	jsr rol1
	clc
	lda DST
	adc #4			; i++
	sta DST

	dex
	bne -

	ldx #.w_next-.w-1
-	lda .w_next,x
	sta .w,x
	dex
	bpl -

	ldy #0
	rts

;;; 32-bit, big-endian math routines.
;;; Result goes in DST. Second operand (if any)
;;; comes from SRC.

	;; Rotate-left DST. Burns a,y.
rol1:
	ldy #0
	lda (DST),y
	rol
	ldy #3
-	lda (DST),y
	rol
	sta (DST),y
	dey
	bpl -
	rts

	;; Rotate-right DST. Burns a,y.
ror1:
	ldy #3
	lda (DST),y
	ror
	ldy #0
	php
-	lda (DST),y
	plp
	ror
	php
	sta (DST),y
	iny
	cpy #4
	bne -
	plp
	rts

	;; Xor SRC into DST. Burns a,y.
xor32:
	ldy #3
-	lda (SRC),y
	eor (DST),y
	sta (DST),y
	dey
	bpl -
	rts

	;; Copy DST to SRC. Burns a,y.
cp32:
	ldy #3
-	lda (SRC),y
	sta (DST),y
	dey
	bpl -
	rts

add32:
	clc
	ldy #3
-	lda (SRC),y
	adc (DST),y
	sta (DST),y
	dey
	bpl -
	rts

and32:
	clc
	ldy #3
-	lda (SRC),y
	and (DST),y
	sta (DST),y
	dey
	bpl -
	rts

or32:
	clc
	ldy #3
-	lda (SRC),y
	ora (DST),y
	sta (DST),y
	dey
	bpl -
	rts

	;; Rotate DST right by 8 bits. Burns a,x,y.
rol8:
	ldy #0
	lda (DST),y
	tax
-	iny
	lda (DST),y
	dey
	sta (DST),y
	iny
	cpy #3
	bne -
	txa
	sta (DST),y
	rts
} ;shasum
