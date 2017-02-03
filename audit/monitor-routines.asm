!zone monitor {

.LOC0     =   $00
.LOC1     =   $01
.WNDLFT   =   $20
.WNDWDTH  =   $21
.WNDTOP   =   $22
.WNDBTM   =   $23
.CH       =   $24
.CV       =   $25
.GBASL    =   $26
.GBASH    =   $27
.BASL     =   $28
.BASH     =   $29
.BAS2L    =   $2A
.BAS2H    =   $2B
.V2       =   $2D
.MASK     =   $2E
.COLOR    =   $30
.INVFLG   =   $32
.YSAV1    =   $35
.CSWL     =   $36
.CSWH     =   $37
.KSWL     =   $38
.KSWH     =   $39
.A2L      =   $3E
.STATUS   =   $48
.RNDL     =   $4E
.RNDH     =   $4F


.IOADR    =   $C000
.KBD      =   $C000
.KBDSTRB  =   $C010
.SPKR     =   $C030
.LORES    =   $C056
.LOWSCR   =   $C054
.TXTSET   =   $C051
.TXTCLR   =   $C050
.MIXSET   =   $C053

.PLOT    LSR              ;Y-COORD/2
         PHP              ;SAVE LSB IN CARRY
         JSR   .GBASCALC  ;CALC BASE ADR IN GBASL,H
         PLP              ;RESTORE LSB FROM CARRY
         LDA   #$0F       ;MASK $0F IF EVEN
         BCC   .RTMASK
         ADC   #$E0       ;MASK $F0 IF ODD
.RTMASK  STA   .MASK
.PLOT1   LDA   (.GBASL),Y ;DATA
         EOR   .COLOR     ; EOR COLOR
         AND   .MASK      ;  AND MASK
         EOR   (.GBASL),Y ;   EOR DATA
         STA   (.GBASL),Y ;    TO DATA
         RTS

.VLINEZ  ADC   #$01       ;NEXT Y-COORD
.VLINE   PHA              ; SAVE ON STACK
         JSR   .PLOT      ; PLOT SQUARE
         PLA
         CMP   .V2        ;DONE?
         BCC   .VLINEZ    ; NO, LOOP
.RTS1    RTS
.CLRSCR  LDY   #$2F       ;MAX Y, FULL SCRN CLR
         BNE   .CLRSC2    ;ALWAYS TAKEN
.CLRTOP  LDY   #$27       ;MAX Y, TOP SCREEN CLR
.CLRSC2  STY   .V2        ;STORE AS BOTTOM COORD
                          ; FOR VLINE CALLS
         LDY   #$27       ;RIGHTMOST X-COORD (COLUMN)
.CLRSC3  LDA   #$00       ;TOP COORD FOR VLINE CALLS
         STA   .COLOR     ;CLEAR COLOR (BLACK)
         JSR   .VLINE     ;DRAW VLINE
         DEY              ;NEXT LEFTMOST X-COORD
         BPL   .CLRSC3    ;LOOP UNTIL DONE
         RTS
.GBASCALC PHA             ;FOR INPUT 000DEFGH
         LSR
         AND   #$03
         ORA   #$04       ;  GENERATE GBASH=000001FG
         STA   .GBASH
         PLA              ;  AND GBASL=HDEDE000
         AND   #$18
         BCC   .GBCALC
         ADC   #$7F
.GBCALC  STA   .GBASL
         ASL
         ASL
         ORA   .GBASL
         STA   .GBASL
         RTS

PRNTYX   TYA
.PRNTAX  JSR   PRBYTE     ;OUTPUT TARGET ADR
.PRNTX   TXA              ;  OF BRANCH AND RETURN
         JMP   PRBYTE

.INIT    LDA   #$00       ;CLR STATUS FOR DEBUG
         STA   .STATUS    ;  SOFTWARE
         LDA   .LORES
         LDA   .LOWSCR    ;INIT VIDEO MODE
.SETTXT  LDA   .TXTSET    ;SET FOR TEXT MODE
         LDA   #$00       ;  FULL SCREEN WINDOW
         BEQ   .SETWND
.SETGR   LDA   .TXTCLR    ;SET FOR GRAPHICS MODE
         LDA   .MIXSET    ;  LOWER 4 LINES AS
         JSR   .CLRTOP    ;  TEXT WINDOW
         LDA   #$14
.SETWND  STA   .WNDTOP    ;SET FOR 40 COL WINDOW
         LDA   #$00       ;  TOP IN A-REG,
         STA   .WNDLFT    ;  BTTM AT LINE 24
         LDA   #$28
         STA   .WNDWDTH
         LDA   #$18
         STA   .WNDBTM    ;  VTAB TO ROW 23
         LDA   #$17
.TABV    STA   .CV        ;VTABS TO ROW IN A-REG
         JMP   .VTAB

.BASCALC PHA              ;CALC BASE ADR IN BASL,H
         LSR              ;  FOR GIVEN LINE NO
         AND   #$03       ;  0<=LINE NO.<=$17
         ORA   #$04       ;ARG=000ABCDE, GENERATE
         STA   .BASH      ;  BASH=000001CD
         PLA              ;  AND
         AND   #$18       ;  BASL=EABAB000
         BCC   .BSCLC2
         ADC   #$7F
.BSCLC2  STA   .BASL
         ASL
         ASL
         ORA   .BASL
         STA   .BASL
         RTS
.BELL1   CMP   #$87       ;BELL CHAR? (CNTRL-G)
         BNE   .RTS2B     ;  NO, RETURN
         LDA   #$40       ;DELAY .01 SECONDS
         JSR   .WAIT
         LDY   #$C0
.BELL2   LDA   #$0C       ;TOGGLE SPEAKER AT
         JSR   .WAIT      ;  1 KHZ FOR .1 SEC.
         LDA   .SPKR
         DEY
         BNE   .BELL2
.RTS2B   RTS
.STOADV  LDY   .CH        ;CURSOR H INDEX TO Y-REG
         STA   (.BASL),Y  ;STORE CHAR IN LINE
.ADVANCE INC   .CH        ;INCREMENT CURSOR H INDEX
         LDA   .CH        ;  (MOVE RIGHT)
         CMP   .WNDWDTH   ;BEYOND WINDOW WIDTH?
         BCS   .CR        ;  YES CR TO NEXT LINE
.RTS3    RTS              ;  NO,RETURN
.VIDOUT  CMP   #$A0       ;CONTROL CHAR?
         BCS   .STOADV    ;  NO,OUTPUT IT.
         TAY              ;INVERSE VIDEO?
         BPL   .STOADV    ;  YES, OUTPUT IT.
         CMP   #$8D       ;CR?
         BEQ   .CR        ;  YES.
         CMP   #$8A       ;LINE FEED?
         BEQ   .LF        ;  IF SO, DO IT.
         CMP   #$88       ;BACK SPACE? (CNTRL-H)
         BNE   .BELL1     ;  NO, CHECK FOR BELL.
.BS      DEC   .CH        ;DECREMENT CURSOR H INDEX
         BPL   .RTS3      ;IF POS, OK. ELSE MOVE UP
         LDA   .WNDWDTH   ;SET CH TO WNDWDTH-1
         STA   .CH
         DEC   .CH        ;(RIGHTMOST SCREEN POS)
.UP      LDA   .WNDTOP    ;CURSOR V INDEX
         CMP   .CV
         BCS   .RTS4      ;IF TOP LINE THEN RETURN
         DEC   .CV        ;DEC CURSOR V-INDEX
.VTAB    LDA   .CV        ;GET CURSOR V-INDEX
.VTABZ   JSR   .BASCALC   ;GENERATE BASE ADR
         ADC   .WNDLFT    ;ADD WINDOW LEFT INDEX
         STA   .BASL      ;TO BASL
.RTS4    RTS

.CLEOP1  PHA              ;SAVE CURRENT LINE ON STK
         JSR   .VTABZ     ;CALC BASE ADDRESS
         JSR   .CLEOLZ    ;CLEAR TO EOL, SET CARRY
         LDY   #$00       ;CLEAR FROM H INDEX=0 FOR REST
         PLA              ;INCREMENT CURRENT LINE
         ADC   #$00       ;(CARRY IS SET)
         CMP   .WNDBTM    ;DONE TO BOTTOM OF WINDOW?
         BCC   .CLEOP1    ;  NO, KEEP CLEARING LINES
         BCS   .VTAB      ;  YES, TAB TO CURRENT LINE
HOME     LDA   .WNDTOP    ;INIT CURSOR V
         STA   .CV        ;  AND H-INDICES
         LDY   #$00
         STY   .CH        ;THEN CLEAR TO END OF PAGE
         BEQ   .CLEOP1
.CR      LDA   #$00       ;CURSOR TO LEFT OF INDEX
         STA   .CH        ;(RET CURSOR H=0)
.LF      INC   .CV        ;INCR CURSOR V(DOWN 1 LINE)
         LDA   .CV
         CMP   .WNDBTM    ;OFF SCREEN?
         BCC   .VTABZ     ;  NO, SET BASE ADDR
         DEC   .CV        ;DECR CURSOR V (BACK TO BOTTOM)
.SCROLL  LDA   .WNDTOP    ;START AT TOP OF SCRL WNDW
         PHA
         JSR   .VTABZ     ;GENERATE BASE ADR
.SCRL1   LDA   .BASL      ;COPY BASL,H
         STA   .BAS2L     ;  TO BAS2L,H
         LDA   .BASH
         STA   .BAS2H
         LDY   .WNDWDTH   ;INIT Y TO RIGHTMOST INDEX
         DEY              ;  OF SCROLLING WINDOW
         PLA
         ADC   #$01       ;INCR LINE NUMBER
         CMP   .WNDBTM    ;DONE?
         BCS   .SCRL3     ;  YES, FINISH
         PHA
         JSR   .VTABZ     ;FORM BASL,H (BASE ADDR)
.SCRL2   LDA   (.BASL),Y  ;MOVE A CHR UP ON LINE
         STA   (.BAS2L),Y
         DEY              ;NEXT CHAR OF LINE
         BPL   .SCRL2
         BMI   .SCRL1     ;NEXT LINE (ALWAYS TAKEN)
.SCRL3   LDY   #$00       ;CLEAR BOTTOM LINE
         JSR   .CLEOLZ    ;GET BASE ADDR FOR BOTTOM LINE
         BCS   .VTAB      ;CARRY IS SET
.CLREOL  LDY   .CH        ;CURSOR H INDEX
.CLEOLZ  LDA   #$A0
.CLEOL2  STA   (.BASL),Y  ;STORE BLANKS FROM 'HERE'
         INY              ;  TO END OF LINES (WNDWDTH)
         CPY   .WNDWDTH
         BCC   .CLEOL2
         RTS
.WAIT    SEC
.WAIT2   PHA
.WAIT3   SBC   #$01
         BNE   .WAIT3     ;1.0204 USEC
         PLA              ;(13+27/2*A+5/2*A*A)
         SBC   #$01
         BNE   .WAIT2
         RTS

KEYIN    INC   .RNDL
         BNE   .KEYIN2    ;INCR RND NUMBER
         INC   .RNDH
.KEYIN2  BIT   .KBD       ;KEY DOWN?
         BPL   KEYIN      ;  LOOP
         STA   (.BASL),Y  ;REPLACE FLASHING SCREEN
         LDA   .KBD       ;GET KEYCODE
         BIT   .KBDSTRB   ;CLR KEY STROBE
         RTS

CROUT    LDA   #$8D
         BNE   COUT

PRBYTE   PHA              ;PRINT BYTE AS 2 HEX
         LSR              ;  DIGITS, DESTROYS A-REG
         LSR
         LSR
         LSR
         JSR   .PRHEXZ
         PLA
.PRHEX   AND   #$0F       ;PRINT HEX DIG IN A-REG
.PRHEXZ  ORA   #$B0       ;  LSB'S
         CMP   #$BA
         BCC   COUT
         ADC   #$06
COUT     JMP   (.CSWL)    ;VECTOR TO USER OUTPUT ROUTINE
COUT1    CMP   #$A0
         BCC   .COUTZ     ;DON'T OUTPUT CTRL'S INVERSE
         AND   .INVFLG    ;MASK WITH INVERSE FLAG
.COUTZ   STY   .YSAV1     ;SAV Y-REG
         PHA              ;SAV A-REG
         JSR   .VIDOUT    ;OUTPUT A-REG AS ASCII
         PLA              ;RESTORE A-REG
         LDY   .YSAV1     ;  AND Y-REG
         RTS              ;  THEN RETURN

.SETNORM LDY   #$FF       ;SET FOR NORMAL VID
.SETIFLG STY   .INVFLG
         RTS
.SETKBD  LDA   #$00       ;SIMULATE PORT #0 INPUT
.INPORT  STA   .A2L       ;  SPECIFIED (KEYIN ROUTINE)
.INPRT   LDX   #.KSWL
         LDY   #<KEYIN
         BNE   .IOPRT
.SETVID  LDA   #$00       ;SIMULATE PORT #0 OUTPUT
.OUTPORT STA   .A2L       ;  SPECIFIED (COUT1 ROUTINE)
.OUTPRT  LDX   #.CSWL
         LDY   #<COUT1
.IOPRT   LDA   .A2L       ;SET RAM IN/OUT VECTORS
         AND   #$0F
         BEQ   .IOPRT1
         ORA   #>.IOADR
         LDY   #$00
         BEQ   .IOPRT2
.IOPRT1  LDA   #>COUT1
.IOPRT2  STY   .LOC0,X
         STA   .LOC1,X
         RTS

RESET    JSR   .SETNORM   ;SET SCREEN MODE
         JSR   .INIT      ;  AND INIT KBD/SCREEN
         JSR   .SETVID    ;  AS I/O DEV'S
         JSR   .SETKBD
         CLD              ;MUST SET HEX MODE!
         RTS

} ; monitor
