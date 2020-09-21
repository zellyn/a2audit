;;; Apple IIe Auxiliary memory audit routines
;;; Copyright © 2017 Zellyn Hunter <zellyn@gmail.com>

!zone auxmem {

	.MEM_1 = %00000000
	.MEM_2 = %00000001
	.MEM_3 = %00000010
	.MEM_4 = %00000011
	.MEM_2_1_1_1 = (.MEM_2 << 0) + (.MEM_1 << 2) + (.MEM_1 << 4) + (.MEM_1 << 6)
	.MEM_3_2_2_2 = (.MEM_3 << 0) + (.MEM_2 << 2) + (.MEM_2 << 4) + (.MEM_2 << 6)

	.C_8f = %0001
	.C_12 = %0010
	.C_47 = %0100
	.C_3  = %1000
	.C_0  = %0000
	.C_skip = $80
	.C_1348 = .C_12 | .C_3 | .C_47 | .C_8f
	.C_38 = .C_3 | .C_8f

	.checkdata = tmp1
	.ismain = tmp3
	.region = tmp4
	.actual = tmp1
	.desired = tmp2


AUXMEMTESTS
	lda #0
	sta AUXRESULT
	lda MEMORY
	cmp #65
	bcs +
	+print
	!text "64K OR LESS:SKIPPING AUXMEM TEST",$8D
	+printed
	sec
	rts

+	+print
	!text "TESTING AUX MEM",$8D
	+printed

	lda LCRESULT
	bne .auxlc
	+print
	!text "LC FAILED BEFORE:SKIPPING AUXMEM LC",$8D
	+printed
	jmp .datadriventests

.auxlc	;; Run langcard tests in auxmem

	lda LCRESULT
	sta LCRESULT1
	lda #0
	sta LCRESULT

	;; Store distinct values in RAM areas, to see if they stay safe.
	lda $C08B		; Read and write bank 1
	lda $C08B
	lda #$44
	sta $D17B		; $D17B is $53 in Apple II/plus/e/enhanced
	sta $FE1F		; FE1F is $60 in Apple II/plus/e/enhanced
	lda $C083		; Read and write bank 2
	lda $C083
	lda #$44
	sta $D17B

	jsr zptoaux

	sta SET_ALTZP
	jsr LANGCARDTESTS_NO_CHECK
	sta RESET_ALTZP

	jsr zpfromaux

	lda LCRESULT
	bne +

	+prerr $0008 ;; E0008: We tried to run the langcard tests again with auxmem (ALTZP active), and they failed, so we're quitting the auxmem test.
	!text "QUITTING AUXMEM TEST DUE TO LC FAIL",$8D
	+prerred
	sec
	rts

	;; Check that the stuff we stashed in main RAM was unaffected.
+
	lda $C088		; Read bank 1
	lda $D17B
	cmp #$44
	beq +
	pha
	+print
	!text "WANT BANK1 $D17B"
	+printed
	beq .lcerr

+	lda $C080		; Read bank 2
	lda $D17B
	cmp #$44
	beq +
	pha
	+print
	!text "WANT BANK2 $D17B"
	+printed
	beq .lcerr

+
	lda $FE1F
	cmp #$44
	beq .datadriventests
	pha
	+print
	!text "WANT RAM $FE1F"
	+printed

.lcerr
	+print
	!text "=$44;GOT $"
	+printed
	pla
	jsr PRBYTE
	+prerr $0009 ;; E0009: We wrote $44 to main RAM in the three test locations used by the LC test. They should have been unaffected by the LC test while it was using auxmem, but at least one of them was modified.
	!text ""
	+prerred
	sec
	rts

.success
	lda #' '
	sta $427
	+print
	!text "AUXMEM TESTS SUCCEEDED",$8D
	+printed
	lda #1
	sta AUXRESULT
	clc
	rts

;;; Main data-driven test. PCL,PCH holds the address of the next
;;; data-driven test routine. We expect the various softswitches
;;; to be reset each time we loop at .ddloop.
.datadriventests
	lda #<.auxtests
	sta PCL
	lda #>.auxtests
	sta PCH
;;; Main data-drive-test loop.
.ddloop
	ldy #0
	lda (PCL),Y
	beq .success

	lda #3
	sta SET_ALTZP
	sta SET_RAMWRT
	sta SET_RAMRD

.initloop			; Loop twice: initialize aux to $3 and main to $1.
	ldy #.memorylen
-	ldx .memorylocs,y
	stx + +1
	ldx .memorylocs+1,y
	stx + +2
+	sta $ffff ;; this address gets replaced
	dey
	dey
	bpl -

	sta RESET_ALTZP
	sta RESET_RAMWRT
	sta RESET_RAMRD

	sec
	sbc #2
	bcs .initloop

	jmp (PCL)		; Jump to test routine.

	;; Test routine will JSR back to here, so the check data address is on the stack.
	;; .checkdata (tmp1/tmp2) is the pointer to the current checkdata byte
	;; .ismain (tmp3) is the main/aux loop counter.
	;; .region (tmp4) is the zp/main/text/hires loop counter
.check
	;; Increment all the test memory locations, so we can see what we were reading and writing.
	inc $ff
	inc $100
	inc $200
	inc $3ff
	inc $427
	inc $7ff
	inc $800
	inc $1fff
	inc $2000
	inc $3fff
	inc $4000
	inc $5fff
	inc $bfff

	;; pull address off of stack: it points just below check data for this test.
	pla
	sta .checkdata
	pla
	sta .checkdata+1

	;; First checkdata byte is for Cxxx tests.
	jsr NEXTCHECK
	bmi +
	jsr .checkCxxx

+	ldx .checkdata
	ldy .checkdata+1
	jsr RESETALL
	stx .checkdata
	sty .checkdata+1

	;; Do the next part twice.
	lda #1
	sta .ismain
	jsr NEXTCHECK
.checkloop			; Loop twice here: once for main, once for aux.
	lda #4
	sta .region
	ldx #$fe
	ldy #0

.memlp	inx
	inx
	lda .memorylocs,x
	sta SRC
	lda .memorylocs+1,x
	sta SRC+1
	ora SRC
	beq .memlpinc

	;; Perform the actual memory check.
	lda (SRC),y
	cmp (.checkdata),y
	bne .checkerr
	beq .memlp

.memlpinc
	jsr NEXTCHECK
	dec .region		; loop four times: zero, main, text, hires
	bne .memlp

	dec .ismain
	bmi .checkdone
	ldx .checkdata
	ldy .checkdata+1
	lda .ismain
	sta SET_ALTZP
	sta SET_RAMRD
	sta SET_RAMWRT
	stx .checkdata
	sty .checkdata+1
	sta .ismain
	jmp .checkloop

.checkdone
	;; Jump PCL,PCH to next test, and loop.
	ldx .checkdata
	ldy .checkdata+1
	jsr RESETALL
	stx PCL
	sty PCH
	jmp .ddloop

.checkerr
	;; X = index of memory location
	;; A = actual
	;; Y = 0
	;; desired = (.checkdata),y
	pha
	lda .ismain
	clc
	ror
	ror
	ora (.checkdata),y
	tay
	pla

	;; Now:
	;; X = index of memory location
	;; A = actual
	;; Y = desired | (high bit set if main, unset=aux)

	jsr RESETALL

	sta .actual
	sty .desired
	lda .memorylocs,x
	sta SRC
	lda .memorylocs+1,x
	sta SRC+1

	+print
	!text "GOT $"
	+printed
	lda .actual
	jsr PRBYTE
	+print
	!text " AT $"
	+printed
	ldx SRC
	ldy SRC+1
	jsr PRNTYX

	lda .desired
	bpl +
	eor #$80
	sta .desired
	+print
	!text " OF MAIN MEM (WANT $"
	+printed
	beq ++
+	+print
	!text " OF AUX MEM (WANT $"
	+printed
++
	lda .desired
	jsr PRBYTE
	lda #')'
	jsr COUT
	lda #$8D
	jsr COUT

	jsr .printtest
	+prerr $000A ;; E000A: This is a data-driven test of main and auxiliary memory softswitch operation. We initialize $FF, $100, $200, $3FF, $427, $7FF, $800, $1FFF, $2000, $3FFF, $4000, $5FFF, and $BFFF in main RAM to value 1, and in auxiliary RAM to value 3. Then, we perform a testdata-driven sequence of instructions. Finally we (try to) increment all test locations. Then we test the expected values of the test locations in main and auxiliary memory. For more information on the operation of the auxiliary memory soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-22 to 5-28.
	!text "FOLLOWED BY INC OF TEST LOCATIONS. SEE"
	+prerred

	sec
	rts

;;; Check that the expected ROM areas are visible.
.checkCxxx
	.gotCxxx = tmp0
	.wantCxxx = SCRATCH
	pha
	jsr .genCxxxFingerprint
	pla
	cmp .gotCxxx
	beq .checkCxxxDone
	lda .gotCxxx

	;; Reset, but copy .checkdata over.
	ldx .checkdata
	ldy .checkdata+1
	jsr RESETALL
	stx .checkdata
	sty .checkdata+1
	sta .gotCxxx
	ldy #0
	lda (.checkdata),y
	sta .wantCxxx

	jsr .printtest
	+print
	!text "WANT:",$8D
	+printed
	lda .wantCxxx
	jsr .printCxxxBits
	+print
	!text "GOT:",$8D
	+printed
	lda .gotCxxx
	jsr .printCxxxBits

	+prerr $000B ;; E000B: This is a the Cxxx-ROM check part of the auxiliary memory data-driven test (see E000A for a description of the other part). After a full reset, we perform a testdata-driven sequence of instructions. Finally we check which parts of Cxxx ROM seem to be visible. We check C100-C2FF, C300-C3FF, C400-C7FF (which should be the same as C100-C2FF), and C800-CFFE. For more details, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-28.
	!text "CXXX ROM TEST FAILED"
	+prerred

	;; Don't continue with auxmem check: return from parent JSR.
	pla
	pla
	sec
	rts

.checkCxxxDone
	rts

.genCxxxFingerprint
	.dataptr = SCRATCH2
	.want = SCRATCH3
	.loopctr = SCRATCH

	lda #0
	sta .gotCxxx
	lda #0
	sta .dataptr
	lda #4
	sta .loopctr

--	clc
	ror .gotCxxx
	ldx #4			; four check bytes per region
	lda #$8			; start out with positive match bit
	ora .gotCxxx
	sta .gotCxxx
-	ldy .dataptr
	lda .cxtestdata,y
	iny
	sta SRC
	lda .cxtestdata,y
	iny
	sta SRC+1
	lda .cxtestdata,y
	iny
	sta .want
	sty .dataptr
	ldy #0
	lda (SRC),y
	cmp .want
	beq +
	lda #($ff-$8)		; mismatch: clear current bit
	and .gotCxxx
	sta .gotCxxx
+	dex
	bne -

	dec .loopctr
	bne --
	rts

.printCxxxBits
	tax
	+print
	!text "- C100-C2FF: "
	+printed
	txa
	and #.C_12
	jsr .printCxxxBit
	+print
	!text "- C300-C3FF: "
	+printed
	txa
	and #.C_3
	jsr .printCxxxBit
	+print
	!text "- C400-C7FF: "
	+printed
	txa
	and #.C_47
	jsr .printCxxxBit
	+print
	!text "- C800-CFFE: "
	+printed
	txa
	and #.C_8f
	jsr .printCxxxBit
	rts

.printCxxxBit
	bne +
	+print
	!text "?",$8D
	+printed
	rts
+	+print
	!text "ROM",$8D
	+printed
	rts

;;; Print out the sequence of instructions at PCL,PCH, until we hit a JSR.
.printtest
	+print
	!text "AFTER SEQUENCE",$8D
	+printed
	jmp PRINTTEST

;;; Copy zero page to aux mem. Assumes zp pointing at main mem, and leaves it that way.
zptoaux
	ldx #0
-	sta RESET_ALTZP
	lda 0,x
	sta SET_ALTZP
	sta 0,x
	inx
	bne -
	sta RESET_ALTZP
	rts

;;; Copy zero page from aux mem. Assumes zp pointing at main mem, and leaves it that way.
zpfromaux
	ldx #0
-	sta SET_ALTZP
	lda 0,x
	sta RESET_ALTZP
	sta 0,x
	inx
	bne -
	rts

.auxtests

	;; Our four basic tests --------------------------------------

	;; Test 1: everything reset.
	lda #1
	jsr .check
	!byte .C_skip, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 2: write to AUX but read from Main RAM, everything else normal.
	lda #2
	sta SET_RAMWRT
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 2, 2, 2

	;; Test 3: write to main but read AUX, everything else normal.
	lda #3
	sta SET_RAMRD
	jsr .check
	!byte .C_skip, 2, 4, 4, 4, 3, 3, 3, 3

	;; Test 4: write to AUX, read from AUX, everything else normal.
	lda #4
	sta SET_RAMRD
	sta SET_RAMWRT
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 4, 4, 4

	;; Our four basic tests, but with 80STORE ON -----------------
	;; (400-7ff is pointing at main mem)

	;; Test 5: everything reset.
	lda #5
	sta SET_80STORE
	jsr .check
	!byte .C_skip, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 6: write to aux
	lda #6
	sta SET_RAMWRT
	sta SET_80STORE
	jsr .check
	!byte .C_skip, 2, 1, 2, 1, 3, 2, 3, 2

	;; Test 7: read from aux
	lda #7
	sta SET_RAMRD
	sta SET_80STORE
	jsr .check
	!byte .C_skip, 2, 4, 2, 4, 3, 3, 3, 3

	;; Test 8: read and write aux
	lda #8
	sta SET_RAMRD
	sta SET_RAMWRT
	sta SET_80STORE
	jsr .check
	!byte .C_skip, 2, 1, 2, 1, 3, 4, 3, 4

	;; Our four basic tests, but with 80STORE and PAGE2 ON -------
	;; (400-7ff is pointing at aux mem)

	;; Test 9: everything reset.
	lda #9
	sta SET_80STORE
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 2, 1, 2, 3, 3, 4, 3

	;; Test A: write to aux
	lda #$a
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 2, 4, 2

	;; Test B: read from aux
	lda #$b
	sta SET_RAMRD
	sta SET_80STORE
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 4, 1, 4, 3, 3, 4, 3

	;; Test C: read and write aux
	lda #$c
	sta SET_RAMRD
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 4, 4, 4

	;; Our four basic tests, but with 80STORE and HIRES ON -------
	;; (400-7ff and 2000-3fff are pointing at main mem)

	;; Test D: everything reset.
	lda #$d
	sta SET_80STORE
	sta SET_HIRES
	jsr .check
	!byte .C_skip, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test E: write to aux
	lda #$e
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_HIRES
	jsr .check
	!byte .C_skip, 2, 1, 2, 2, 3, 2, 3, 3

	;; Test F: read from aux
	lda #$f
	sta SET_RAMRD
	sta SET_80STORE
	sta SET_HIRES
	jsr .check
	!byte .C_skip, 2, 4, 2, 2, 3, 3, 3, 3

	;; Test 10: read and write aux
	lda #$10
	sta SET_RAMRD
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_HIRES
	jsr .check
	!byte .C_skip, 2, 1, 2, 2, 3, 4, 3, 3

	;; Our four basic tests, but with 80STORE, HIRES, PAGE2 ON ---
	;; (400-7ff and 2000-3fff are pointing at aux mem)

	;; Test 11: everything reset.
	lda #$11
	sta SET_80STORE
	sta SET_HIRES
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 2, 1, 1, 3, 3, 4, 4

	;; Test 12: write to aux
	lda #$12
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_HIRES
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 2, 4, 4

	;; Test 13: read from aux
	lda #$13
	sta SET_RAMRD
	sta SET_80STORE
	sta SET_HIRES
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 4, 1, 1, 3, 3, 4, 4

	;; Test 14: read and write aux
	lda #$14
	sta SET_RAMRD
	sta SET_RAMWRT
	sta SET_80STORE
	sta SET_HIRES
	sta SET_PAGE2
	jsr .check
	!byte .C_skip, 2, 1, 1, 1, 3, 4, 4, 4

	;; Test 15: Cxxx test with everything reset.
	lda #$15
	jsr .check
	!byte .C_3, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 16: Cxxx test with SLOTC3ROM set
	lda #$16
	sta SET_SLOTC3ROM
	jsr .check
	!byte .C_0, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 17: Cxxx test with INTCXROM set.
	lda #$17
	sta SET_INTCXROM
	jsr .check
	!byte .C_1348, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 18: Cxxx test with SLOTC3ROM and INTCXROM set
	lda #$18
	sta SET_SLOTC3ROM
	sta SET_INTCXROM
	jsr .check
	!byte .C_1348, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 19: Cxxx test with "INTC8ROM" set
	lda #$19
	lda $C300
	jsr .check
	!byte .C_38, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 1A: Cxxx test showing inability to reset "INTC8ROM" with softswitches.
	lda #$1A
	lda $C300
	sta SET_SLOTC3ROM
	jsr .check
	!byte .C_8f, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 1B: Cxxx test showing ability to reset "INTC8ROM" with CFFF reference.
	lda #$1B
	lda $C300
	sta SET_SLOTC3ROM
	lda RESET_INTC8ROM
	jsr .check
	!byte .C_0, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 1C: Cxxx test showing inability to reset "INTC8ROM" with CFFF reference.
	lda #$1B
	sta SET_SLOTC3ROM
	sta SET_INTCXROM
	lda RESET_INTC8ROM
	jsr .check
	!byte .C_1348, 2, 2, 2, 2, 3, 3, 3, 3

	;; Test 1D: Cxxx test showing that "INTC8ROM" isn't set if SLOTC3ROM isn't reset.
	lda #$1D
	sta SET_INTCXROM
	sta SET_SLOTC3ROM
	lda $C300
	sta RESET_INTCXROM
	jsr .check
	!byte .C_0, 2, 2, 2, 2, 3, 3, 3, 3

	!byte 0 ; end of tests

.memorylocs
	;; zero page locations
	!word $ff, $100, 0
	;; main memory locations
	!word $200, $3ff, $800, $1fff, $4000, $5fff, $bfff, 0
	;; text locations
	!word $427, $7ff, 0
	;; hires locations
	!word $2000, $3fff, 0
	;; end
.memorylen = * - .memorylocs - 2
	!word 0

.cxtestdata
	;; C800-Cffe
	!byte $00, $c8, $4c
	!byte $21, $ca, $8d
	!byte $43, $cc, $f0
	!byte $b5, $ce, $7b

	;; C100-C2ff
	!byte $4d, $c1, $a5
	!byte $6c, $c1, $2a
	!byte $b5, $c2, $ad
	!byte $ff, $c2, $00

	;; C400-C7ff
	!byte $36, $c4, $8d
	!byte $48, $c5, $18
	!byte $80, $c6, $8b
	!byte $6e, $c7, $cb

	;; C300-C3ff
	!byte $00, $c3, $2c
	!byte $0a, $c3, $0c
	!byte $2b, $c3, $04
	!byte $e2, $c3, $ed
} ;auxmem
