;;; Assembly conversion of listings 1 and 2 from
;;; http://rich12345.tripod.com/aiivideo/softalk.html#list2
;;; https://archive.org/stream/softalkv3n02oct1982#page/54/mode/2up

	!convtab <apple ii/convtab.bin>
	!to "apple_split_1.o", plain
	* = $6000

	V2 = $2D 		; bottom point for vertical line drawing
	HOME = $FC58
	SETCOL = $F864
	VLINE = $F828
	MSGPOS = $690
main:

;;; 100 HOME
	JSR HOME

;;; 200 FOR K = 0 TO 39
	LDX #39
loop:
;;; 210 POKE 1448 + K, 14 * 16
	LDA #$E0
	STA 0x5a8,X
;;; 220 POKE 2000 + K, 10 * 16
	LDA #$A0
	STA 0x7D0,X

	TXA
	TAY

;;; 230 COLOR= K + 4
	ADC #4
	JSR SETCOL

;;; 240 VLIN 25,45 AT K
	LDA #45
	STA V2
	LDA #25
	JSR VLINE

;;; 250 NEXT K
	DEX
	BPL loop

;;; 300 VTAB 6: HTAB 17
;;; 310 PRINT "APPLE II"

	LDX #7
msgloop:
	LDA message,X
	STA MSGPOS,X
	DEX
	BPL msgloop

;;; 400 CALL 768
;;; 500 GOTO 400


forever:
	jsr sync
	jmp forever

message:	!text "APPLE II"
sync:
	STA $C052
	LDA #$E0
loop1:
	LDX #$04
loop2:
	CMP $C051
	BNE loop1
	DEX
	BNE loop2
	LDA #$A0
loop3:
	LDX #$04
loop4:
	CMP $C050
	BNE loop3
	DEX
	BNE loop4
	STA $C051
	RTS
