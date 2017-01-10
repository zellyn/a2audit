;;; Apple II ROM shasum audit routines
;;; Copyright © 2016 Zellyn Hunter <zellyn@gmail.com>

	!zone shasumtests {

	!addr	SRC = $06
	!addr	DST = $08
	!addr   SHAINPUT = $eb
	!addr   SHALENGTH = $ee

SHASUMTESTS

	+print
	!text "COMPUTING ROM SHASUM",$8D
	+printed

	lda #0
	sta SHAINPUT
	lda #$E0
	sta SHAINPUT+1
	lda #0
	sta SHALENGTH
	lda #$20
	sta SHALENGTH+1
	jsr SHASUM

	+print
	!text "SHASUM:",$8D
	+printed

	lda #<SHA
	sta SRC
	lda #>SHA
	sta SRC+1
	lda #SHALEN
	jsr prbytes

.done

	rts
	} ;shasumtests

	!eof

	2744ebe53a13578f318fe017d01ea6a975083250

Apple II:             102FBF7DEA8B8D6DE5DE1C484FF45E7B5DFB28D5 (oe, vii)
Apple II Plus:        5a23616dca14e59b4aca8ff6cfa0d98592a78a79 (oe, mame)
                      2744ebe53a13578f318fe017d01ea6a975083250 (vii)
Apple IIe:            8895a4b703f2184b673078f411f4089889b61c54 (mame)
Apple IIe (enhanced): afb09bb96038232dc757d40c0605623cae38088e (vii, mame)
