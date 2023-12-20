; MONITOR PROGRAM FOR 6802 MICROPROCESSOR KIT
; (C) COPYRIGHT 2015 BY WICHIT SIRICHOTE
;
; Source code was translated by tasm assembler with command
; d:>tasm -68 mon68.asm mon68.hex

; 12 September 2015 fix 16-bit variable allocation
;                   HIGH BYTE DISPLAY
;                   LOW BYTE  DISPLAY+1

; 13 September 2015 test single step with 74LS164
;                   8th clock will make NMI low! 
;                   The number of clock must be 7 after the break signal
;                   has been set. So the 8th clock will make NMI low
;                   User instruction will be fetched and executed at the 8th clock.

;                   Add key INS and DEL

; 14 September 2015 provide RAM vector for IRQ at location 00F8H
;                   CPU will jump to 00F8H if IRQ was triggered and Interrupt
;                   mask has been cleared.


; 16 September 2015 Testing single step with 4076
;                   add 4-bit D-FF 4076 to provide 4-bit shifting
;                   use with RTI 10 cycles to make NMI service

; 17 September 2015 Add register display, page zero display

; 18 September 2015 test software UART at 2400 Hz, found half bit 1207Hz,
;                   or 2414Hz, % error = 0.6%           
;                   test receive hex file
; 19 September 2015 add LCD drivers to monitor program
;                   begin test monitor code in RAM @4000h 

; 20 September 2015 add Motorola S record for hex file download command
;                   tested with tasm -68 -g2 led.asm

; 21 September 2015 fix s-record lodaing, check number of byte include load address!
;                    s-record loading was tested with tasm -g2 option

;                   add key mute for beep on/off

;                   prepare to backup the source code!

; 23 September 2015 add cold/warm boot setup

; 25 September 2015 add function copy block of memory and cold message
;                   add hex dump function for displaying hex contents
;                   on 2400 terminal
; 28 Spetember 2015 fix rep key bouncing! when pressed together with key Step
;                   fix ASCII printing with key DUMP

; address of the I/O ports


GPIO1   .EQU 8000H
PORT0   .EQU 8001H
PORT1   .EQU 8002H
PORT2   .EQU 8003H

DIGIT   .EQU 8002H
SEG7    .EQU 8003H
KIN     .EQU 8001H
 

ONE     .EQU 30H
ZERO    .EQU 0BDH


BUSY              .EQU 80H

; below LCD's registers are mapped into memory space

command_write     .EQU 9000H
data_write        .EQU 9001H
command_read      .EQU 9002H
data_read         .EQU 9003H



 ; page zero register definition
 ; LOCATION $00 TO $7F ARE 128 BYTES FOR USER PROGRAM USE 
         
	 .DSEG
	 .ORG 80H

; zero page memory definitions for monitor use       
REG_E   .BLOCK 1
REG_D   .BLOCK 1
REG_B   .BLOCK 1
REG_C   .BLOCK 1
HL      .BLOCK 2           ; 84H = L 85H = H
DE      .BLOCK 2
REG_A   .BLOCK 1

_ERROR  .BLOCK 1           ; ERROR FLAG FOR INTEL HEX FILE DOWNLOADING
BCC     .BLOCK 2           ; BYTE CHECK SUM
BUFFER  .BLOCK 6          ; 8BH - 90H PAGE ZERO DISPLAY BUFFER
INVALID .BLOCK 1          ; INVALID KEY HAS BEEN PRESSED FLAG BIT
                          ; 0 VALID
			  ; 1 INVALID

KEY     .BLOCK 1
STATE   .BLOCK 1
ZERO_FLAG .BLOCK 1          ; ZERO WHEN HEX KEY PRESSED FOR ADDRESS OR DATA KEY

DISPLAY .BLOCK 2         ; display address 

USER_PC  .BLOCK 2       ; FOR SAVING CURRENT PC, ON RESET, IT SETS TO 200H 
USER_A  .BLOCK 1
USER_B  .BLOCK 1 
USER_IX  .BLOCK 2
USER_SP  .BLOCK 2         ; USER STACK POINTER
USER_P  .BLOCK 1         ; PROGRAM STATUS REGISTER
SAVE_SP .BLOCK 2         ; SAVE SYSTEM STACK 

START_ADDRESS .BLOCK 2
DESTINATION  .BLOCK 2    ; FOR OFFSET BYTE CALCULATION  
OFFSET_BYTE .BLOCK 2     ; OFFSET BYTE = DESTINATION - START_ADDRESS

END_ADDRESS .BLOCK 2      ; FOR COPY MEMORY FUNCTION

COLD    .BLOCK 2         ; COLD BOOT OR WARM BOOT

REPDELAY .BLOCK 1

DEBUG    .BLOCK 2      ; FOR PROGRAM DEBUGGING
TEMP16   .BLOCK 2      ; REGISTER 16 BITS

IX2      .BLOCK 2

OFFSET   .BLOCK 2      ; FOR X INDEXT REGISTER USE
BIN2SEG  .BLOCK 16     ; TABLE FOR 4-BIT BINARY TO 7-SEGMENT PATTERN
BEEP_FREQ .BLOCK 1     ; STORE BEEP FREQUENCY
BEEP_PERIOD .BLOCK 2   ; STORE BEEP PERIOD LOAD WITH IX
DEMO_NO   .BLOCK 1     ; FOR DEMO 0-9
MUTE      .BLOCK 1     ; TOGGLE MUTE FOR BEEP ON/OFF 0=BEEP ON
BIT1_COUNTER .BLOCK 1  ; COUNTER FOR BIT 1 TEST


SEC100    .BLOCK 1     ; VARIABLES FOR CLOCK PROGRAM
SEC       .BLOCK 1
MIN       .BLOCK 1
HOUR      .BLOCK 1
RUNSTOP   .BLOCK 1

K         .BLOCK 1     ; GENERAL PURPOSE REGISTERS
J         .BLOCK 1  


 
          .CSEG


          .ORG 0C000H    ; START ADDRESS FOR ROM

   ;       .ORG 4000H     ; TEST IN RAM


START     LDAA #$BF
          STAA PORT1     ; DISABLE NMI BREAK SIGNAL
          LDAA #0
          STAA GPIO1     ; TEST DISPLAY


	; power up delay

                LDX #300
POWER_UP_DELAY	DEX 
	        BNE POWER_UP_DELAY


        LDS #$7FFF     ; SYSTEM STACK

        LDX #$7F00
        STX USER_SP   ; STORE USER STACK


        LDAA #0
        STAA BUFFER
	STAA BUFFER+1
	STAA INVALID   ; CLEAR INVALID FLAG

; INSERT 6502 TEXT 

	LDAA #0AFH
        STAA BUFFER+5
        LDAA #0BFH
	STAA BUFFER+4
	LDAA #0BDH
	STAA BUFFER+3
	LDAA #9BH
	STAA BUFFER+2


	LDAA #0
        STAA STATE    ; INITIAL STATE
	STAA ZERO_FLAG

        LDAA #02
	STAA DISPLAY
        STAA USER_PC
        LDAA #0
	STAA DISPLAY+1
        STAA USER_PC+1

        TPA
        STAA USER_P


        LDAA DISPLAY
	STAA HL
	LDAA DISPLAY+1
	STAA HL+1


        LDX #35H
        STAA BEEP_PERIOD

        LDAA #52H
        STAA BEEP_FREQ

        LDAA #0
        STAA DEMO_NO

        LDX COLD
        CPX #0AA55H
        BEQ SKIP_COLD

; COLD START

        LDX #0AA55H
        STX COLD

        LDAA #0
        STAA MUTE      ; BEEP IS ON

        LDAA #0FFH
        STAA GPIO1


        JSR BEEP

        JSR DISPLAY_START_MSG


        CLRA
        STAA GPIO1



SKIP_COLD

     ;   LDX #TEXT3
     ;   JSR PSTR       ; PRINT TEXT3 TESTING 2400 TERMINAL



          JMP MAIN



;----------------------- 2400 BIT/S SOFTWARE UART ---------------------------------
; one bit delay for 2400 bit/s UART

BIT_DELAY LDAB #61     ; 1207 TESTED WITH 55H @1MHz (4MHz xtal)
LOOP      DECB
          BNE LOOP
	  RTS

; 1.5 bit delay

BIT1_5_DELAY LDAB #92      ; DELAY 1.5 BIT
LOOP1      DECB
          BNE LOOP1
	  RTS

; SEND ASCII LETTER TO TERMINAL
; ENTRY: A

SEND_BYTE: STAA REG_E  ; SAVE ACCUMULATOR
             
          LDAA #3FH    ; start bit is zero
	  STAA PORT1
          BSR BIT_DELAY    ; delay one bit
	  
          LDAA #8      ; 8-data bit wil be sent
	  STAA REG_D
                   
CHK_BIT:   LDAA REG_E
           ANDA #1
	   BEQ SEND_ZERO
          
	   LDAA #0BFH
	   STAA PORT1

           BRA NEXT_BIT
	  
             
SEND_ZERO: LDAA #3FH
           STAA PORT1
           BRA NEXT_BIT
            
NEXT_BIT:  BSR BIT_DELAY
     
           LSR REG_E
	   DEC REG_D
           BNE CHK_BIT
          
           LDAA #0BFH
	   STAA PORT1
           BSR BIT_DELAY

           RTS



; RECEIVE BYTE FROM 2400 BIT/S TERMINAL
; EXIT: A

CIN	 LDAA PORT0 
         ANDA #80H
	 BNE CIN
         
         BSR BIT1_5_DELAY
	 
	 LDAA #7
	 STAA REG_D
	 LDAA #0
	 STAA REG_E

    
            
CHK_BIT_RX   LDAA PORT0
           ANDA #80H
           BNE BIT_IS_ONE
           
           LDAA REG_E
           ANDA #7FH
	   STAA REG_E
           BRA NEXT_BIT_RX
             
BIT_IS_ONE LDAA REG_E
           ORAA #80H
	   STAA REG_E
           BRA NEXT_BIT_RX
            
NEXT_BIT_RX  BSR BIT_DELAY
     
           LSR REG_E

           DEC REG_D
	   BNE CHK_BIT_RX

           BSR BIT_DELAY    ; CENTER OF STOP BIT
           
	   LDAA REG_E 

	   RTS



CR        .EQU 0DH
LF        .EQU 0AH
EOS       .EQU 0 

;NEW LINE
; PRINT CR, LF

NEW_LINE     LDAA #0DH
	     JSR SEND_BYTE
	     LDAA #0AH
	     JSR SEND_BYTE
	     RTS


; WRITE NIBBLE TO TERMINAL

OUT1X        ANDA #0FH  
             
             ADDA #30H 
             CMPA  #3AH
             BLT OUT1X1
             ADDA #7
OUT1X1	     JSR SEND_BYTE
	     RTS


OUT2X        PSHA
             
             LSRA
             LSRA
             LSRA
             LSRA
	     
	   ;  STAA GPIO1

	     JSR OUT1X
             PULA
	     JSR OUT1X
	     RTS

; PRINT LINE OF MEMORY POINTED TO HL

PRINT_LINE   LDAA #16
             STAA J 

PRINT_LINE1
             JSR NEW_LINE
             LDAA #16
             STAA REG_C

             LDX HL
             STX TEMP16  ; FOR ASCII PRINTING
	     
             LDAA HL
	     JSR OUT2X
             LDAA HL+1
	     JSR OUT2X

	     LDAA #':'
	     JSR SEND_BYTE
             LDAA #' '
             JSR SEND_BYTE


PRINT_LINE2  LDX HL

             LDAA 0,X
	     
	     JSR OUT2X
	      
	     LDAA #' '
	     JSR SEND_BYTE
	     
             LDX HL
             INX
             STX HL
	     
	     DEC REG_C
	    
	     BNE PRINT_LINE2
;-----------------------------------

; PRINT ASCII CODE


             LDAA #16
             STAA REG_C
PRINT_IT1
             LDX TEMP16

             LDAA 0,X

             CMPA #20H
             BGE  PRINT_IT

             LDAA #'.'

PRINT_IT     JSR SEND_BYTE

             LDX TEMP16
             INX
             STX TEMP16

             DEC REG_C
             BNE PRINT_IT1

;---------------------------------

             DEC J
             BNE PRINT_LINE1


	     RTS


KEY_DUMP     LDAA #$FF
             STAA MUTE      ;TURN BEEP OFF


             LDX DISPLAY
             STX HL

             JSR PRINT_LINE

             JSR NEW_LINE

             LDX HL
             STX DISPLAY
             JSR STILL_DATA

             RTS





;------------------------------SOFTWARE UART ------------------------


LOOP2      LDAA $0
          STAA GPIO1
          JSR DELAY
          INC $0
          BRA LOOP2

DELAY     LDX #10000
DELAY1    DEX
          BNE DELAY1
          RTS



; CONVERT LOW NIBBLE IN ACCUMULATOR TO 7-SEGMENT PATTERN
; ENTRY: A
; EXIT: A

NIBBLE_7SEG

        LDX  #SEGTAB

        STX   TEMP16

        ADDA TEMP16+1
        STAA TEMP16+1

        LDAA #0
        ADCA TEMP16
        STAA TEMP16

        LDX TEMP16

        LDAA  0,X          ; GET 7-SEGMENT PATTERN

        RTS

; CONVERT BYTE TO 7-SEGMENT PATTERN
; ENTRY: A
; EXIT: DE

BYTE_7SEG   PSHA

            ANDA #0FH
            JSR NIBBLE_7SEG
	    STAA DE

            PULA

            LSRA
            LSRA
            LSRA
            LSRA

	    JSR NIBBLE_7SEG
	    STAA DE+1

            RTS


; CONVERT BYTE TO 7-SEGMENT PATTERN AND SAVE TO DISPLAY BUFFER DATA FIELD
; ENTRY: A

DATA_DISPLAY PSHA   ; SAVE ACCUMULATOR
             JSR BYTE_7SEG
	     LDAA DE
	     STAA BUFFER
	     LDAA DE+1
	     STAA BUFFER+1
             PULA
	     RTS

; CONVERT 16-BIT ADDRESS IN HL AND SAVE IT TO ADDRESS FILED DISPLAY BUFFER
; ENTRY: HL

ADDRESS_DISPLAY

            LDAA HL
	    JSR BYTE_7SEG
	    LDAA DE
            STAA BUFFER+4
	    LDAA DE+1
            STAA BUFFER+5
	    LDAA HL+1
	    JSR BYTE_7SEG
	    LDAA DE
            STAA BUFFER+2
	    LDAA DE+1
            STAA BUFFER+3
	    RTS


; CONVERT ASCII TO HEX
; ENTRY: A

TO_HEX     
           SUBA #30H
           CMPA #10H
           BLT ZERO_NINE
           ANDA #11011111B
           SUBA #7

ZERO_NINE  RTS

; CONVERT TWO ASCII LETTERS  TO SINGLE BYTE
; EXIT: A

GET_HEX    JSR CIN       
	   JSR TO_HEX
           ASLA
           ASLA
           ASLA
           ASLA

	   STAA GPIO1
	   
	   STAA REG_A
	   
	   JSR CIN
	   JSR TO_HEX
           ORAA REG_A

	   RTS


ADD_BCC   ADDA BCC
	  STAA BCC
	  RTS


                       

; get hex file for both Intel and Motorola s record automatically
;
; GET_RECORD READS INTEL HEX FILE AND SAVE TO MEMORY

GET_RECORD LDAA #0
	   STAA _ERROR

GET_RECORD1 JSR CIN
           CMPA #':'
	   BEQ GET_RECORD2
	   
           CMPA #'S'          ; if it was Motorola s record
           BNE GET_RECORD1

           JMP GET_S_RECORD2

	   
GET_RECORD2

	   LDAA #0	
	   STAA BCC
	 
	   JSR GET_HEX
	   STAA REG_C     ; GET NUMBER OF BYTE
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STAA HL
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STAA HL+1        ; GET LOAD ADDRESS

	   JSR ADD_BCC

	   JSR GET_HEX

           CMPA #0

	   BEQ DATA_RECORD
	   
WAIT_CR	   JSR CIN
           CMPA #0DH
	   BNE WAIT_CR
	   
	   STAA GPIO1
	   
	   LDAA _ERROR
           CMPA #1
	   BNE NOERROR

; SHOW ERROR ON LED
	;  JSR OUT_OFF_RANGE
	   
	   STAA GPIO1

NOERROR   
           RTS

DATA_RECORD

	   JSR GET_HEX
           LDX  HL
           STAA 0,X  ; WRITE TO MEMORY
	   
	   JSR ADD_BCC

	   STAA GPIO1
	   
           INX
           STX HL
	   
	   DEC REG_C
	   BNE DATA_RECORD ; UNTIL C=0

           LDAA BCC
           EORA #0FFH    ; ONE'S COMPLEMENT
           INCA
                         ; TWO'S COMPLEMENT
	   STAA BCC
	   
	   
	   JSR GET_HEX	   ; GET BYTE CHECK SUM
	   
           CMPA BCC      ; COMPARE WITH BYTE CHECK SUM
	   BEQ SKIP11
	  
	   LDAA #1
	   STAA _ERROR    ; ERROR FLAG =1
	   
	   
SKIP11
	   
	   JMP GET_RECORD1     ; NEXT LINE 




; Motorola s record downloading subrouitne

; S1 14 0200 8601B780008D034920F8CE07D00926FD39 30
;
; S1 0A 0218 CE13880926FD39 0D
; 
; S9 03 0000 FC
;
; 14 is pair count for remaining pair

GET_S_RECORD LDAA #0
	   STAA _ERROR



GET_S_RECORD1

           JSR CIN
           CMPA #'S'
           BNE GET_S_RECORD1

GET_S_RECORD2

           JSR CIN
           CMPA #'1'
           BEQ GET_S1

           CMPA #'9'
           BEQ END_OF_RECORD

           BRA GET_S_RECORD1

GET_S1

	   LDAA #0	
	   STAA BCC
	 
	   JSR GET_HEX
           STAA REG_C     ; GET NUMBER OF pairs
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STAA HL

           DEC REG_C
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STAA HL+1        ; GET LOAD ADDRESS

           DEC REG_C

	   JSR ADD_BCC

           DEC REG_C        ; BYTE COUNT-1 FOR BCC

           BRA DATA_S_RECORD
	   
END_OF_RECORD

           JSR CIN
           CMPA #0DH         ; END OF LINE 0D,0A
           BNE END_OF_RECORD
	   
	   STAA GPIO1
	   
	   LDAA _ERROR
           CMPA #1
           BNE NOERROR2

; SHOW ERROR ON LED
	;  JSR OUT_OFF_RANGE
	   
	   STAA GPIO1

NOERROR2   
           RTS


DATA_S_RECORD

	   JSR GET_HEX
           LDX  HL
           STAA 0,X  ; WRITE TO MEMORY
	   
	   JSR ADD_BCC

	   STAA GPIO1
	   
           INX
           STX HL
	   
	   DEC REG_C
           BNE DATA_S_RECORD ; UNTIL C=0

           LDAA BCC
           EORA #0FFH    ; ONE'S COMPLEMENT
	   STAA BCC
	   
	   
	   JSR GET_HEX	   ; GET BYTE CHECK SUM
	   
           CMPA BCC      ; COMPARE WITH BYTE CHECK SUM
           BEQ SKIP21
	  
	   LDAA #1
	   STAA _ERROR    ; ERROR FLAG =1
	   
	   
SKIP21
	   
           JMP GET_S_RECORD1     ; NEXT LINE 








































;**************************************************************************************88
;
; EXECUTE FUNCTIONS OR HEX KEY ENTERED 
; CHECK HEX KEY OR FUNCTIONS KEY
; ENTRY: A

KEYEXE     CMPA #10H
           BGE FUNCTION_KEY

;HHHHHHHHHHHHHHH   KEY HEX ENTERED HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

           STAA REG_C     ; SAVE HEX KEY
           LDAA STATE

           CMPA #1
           BNE CHK_STATE2
	   
	   LDAA REG_C
	   JMP HEX_ADDR

CHK_STATE2 CMPA #2
           BNE CHK_STATE3
	   JMP HEX_DATA

CHK_STATE3 CMPA #3
           BNE CHK_STATE5
	   JMP HEX_REG

CHK_STATE5 CMPA #5
           BNE CHK_STATE6
	   JMP HEX_REL

CHK_STATE6 CMPA #6
           BNE CHK_STATE7
	   JMP HEX_REL6

CHK_STATE7 CMPA #7
           BNE CHK_STATE8
           JMP HEX_SEND_FILE

CHK_STATE8  CMPA #8
            BNE CHK_STATE9
	    JMP HEX_SEND_FILE2

CHK_STATE9  CMPA #30
            BNE CHK_STATE10
            JMP HEX_COPY31

CHK_STATE10 CMPA #31
            BNE CHK_STATE11
            JMP HEX_COPY32

CHK_STATE11 CMPA #32
            BNE CHK_STATE12
            JMP HEX_COPY33


CHK_STATE12


            LDAA REG_C
            STAA GPIO1
            LDAA #1         ; INVALID KEY PRESSED
	    STAA INVALID
	    




; HEX KEY WAS PRESSED

           
	   RTS





















;FFFFFFFFFFFFFFFFFFFFFF FUNCTION KEY FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

FUNCTION_KEY

          CMPA #19H    ; KEY ADDR
	  BNE CHK_FUNC1
	  JMP KEY_ADDR

CHK_FUNC1 CMPA #14H   ; KEY DATA
          BNE CHK_FUNC2
	  JMP KEY_DATA



CHK_FUNC2 CMPA #10H   ; KEY +
          BNE CHK_FUNC3
	  JMP KEY_INC

CHK_FUNC3 CMPA #11H    ; KEY -
          BNE CHK_FUNC4
	  JMP KEY_DEC

CHK_FUNC4  CMPA #18H
           BNE CHK_FUNC5
	   JMP KEY_PC

CHK_FUNC5  CMPA #1BH
           BNE CHK_FUNC6
	   JMP KEY_REG

CHK_FUNC6  CMPA #12H
           BNE CHK_FUNC7
	   JMP KEY_GO

CHK_FUNC7  CMPA #1DH
           BNE CHK_FUNC8
	   JMP KEY_REL

CHK_FUNC8  CMPA #1FH
           BNE CHK_FUNC9
	   JMP KEY_DOWNLOAD_HEX

CHK_FUNC9 CMPA #13H
          BNE CHK_FUNC10
	  JMP KEY_STEP
          
	  
CHK_FUNC10 CMPA #16H
           BNE CHK_FUNC11
	   JMP KEY_INS

CHK_FUNC11 CMPA #17H
           BNE CHK_FUNC12
	   JMP KEY_DEL

CHK_FUNC12 CMPA #15H
           BNE CHK_FUNC13
           JMP KEY_DEMO   ; CHANGE SBR KEY TO DEMO


CHK_FUNC13 CMPA #1AH
           BNE CHK_FUNC14
           JMP KEY_MUTE   ; TURN BEEP ON/OFF

CHK_FUNC14 CMPA #1CH      ;
           BNE CHK_FUNC15
           JMP KEY_COPY

CHK_FUNC15 CMPA #1EH
           BNE CHK_FUNC16
           JMP KEY_DUMP

CHK_FUNC16


           RTS


;---------------------------------------------------------
KEY_ADDR     LDAA #1
             STAA STATE     ; STAATE =1 FOR ADDRESS MODE

	     LDAA #0
	     STAA ZERO_FLAG
	     
STILL_ADDRESS
             JSR READ_MEMORY
	     
	     LDAA BUFFER+5
             ORAA #40H
	     STAA BUFFER+5

	     LDAA BUFFER+4
             ORAA #40H
	     STAA BUFFER+4

	     LDAA BUFFER+3
             ORAA #40H
	     STAA BUFFER+3

             LDAA BUFFER+2
             ORAA #40H
	     STAA BUFFER+2

             LDAA BUFFER+1
             ANDA #~40H
	     STAA BUFFER+1

	     LDAA BUFFER
             ANDA #~40H
	     STAA BUFFER

             RTS

;---------------------------------------------------------

KEY_DATA     LDAA #2
             STAA STATE     ; STATE =2 FOR DATA MODE

	      LDAA #0
	     STAA ZERO_FLAG

STILL_DATA   JSR READ_MEMORY 

	     LDAA BUFFER+5
             ANDA #~40H
	     STAA BUFFER+5

	     LDAA BUFFER+4
             ANDA #~40H
	     STAA BUFFER+4

	     LDAA BUFFER+3
             ANDA #~40H
	     STAA BUFFER+3

             LDAA BUFFER+2
             ANDA #~40H
	     STAA BUFFER+2

             LDAA BUFFER+1
             ORAA #40H
	     STAA BUFFER+1

	     LDAA BUFFER
             ORAA #40H
	     STAA BUFFER

             RTS


; READ MEMORY

READ_MEMORY

        LDAA DISPLAY
	STAA HL
	LDAA DISPLAY+1
	STAA HL+1
	JSR ADDRESS_DISPLAY

        LDX   HL
        LDAA 0,X
	
	;STAA GPIO1

	JSR DATA_DISPLAY
	RTS




; KEY PC, SET CURRENT USER ADDRESS

KEY_PC      LDAA #2
            STAA STATE     ; STAATE =2 FOR DATA MODE

	    LDAA #0
	    STAA ZERO_FLAG

            LDAA USER_PC
	    STAA DISPLAY
            LDAA USER_PC+1       
	    STAA DISPLAY+1
           ; JSR READ_MEMORY
	    JSR STILL_DATA
	    RTS

; KEY REGISTER
; SET STATE TO 3 FOR REGISTER INPUT WITH HEX KEY

KEY_REG    LDAA #3
           STAA STATE  ; STAATE = 3 FOR REGISTER DISPLAY

	   LDAA #3
	   STAA BUFFER+5
	   LDAA #8FH
	   STAA BUFFER+4
	   LDAA #0BEH
	   STAA BUFFER+3
           LDAA #0
	   STAA BUFFER+2
	   LDAA #0
	   STAA BUFFER+1
	   STAA BUFFER

	   RTS

; INCREMENT CURRENT ADDRESS BY ONE
;

KEY_INC     LDAA STATE
            CMPA #20
            BNE SKIP_INC1

            INC DEMO_NO
            LDAA DEMO_NO
            CMPA #10
            BLT SKIP_INC2
            LDAA #0
            STAA DEMO_NO


SKIP_INC2   JSR DATA_DISPLAY
            RTS





SKIP_INC1   LDAA STATE
            CMPA #5
	    BEQ REL_KEY_PRESSED

            CMPA #7
	    BEQ SEND_INC1


            CMPA #30
            BEQ COPY_KEY_PRESSED

            CMPA #31
            BEQ COPY_KEY_PRESSED1



; NORMAL INCREMENT CURRENT ADDRESS BY ONE

            LDAA #2
            STAA STATE     ; STATE =2 FOR DATA MODE

	    LDAA #0
	    STAA ZERO_FLAG
            

             LDX DISPLAY
             INX
             STX DISPLAY


            ; JSR READ_MEMORY
	     JSR STILL_DATA
	     RTS



COPY_KEY_PRESSED1
             
             ; Save ENDING address


             LDX DISPLAY
             STX END_ADDRESS

             LDAA #32           ; STATE 32 FOR KEY GO COPYING MEMORY
             STAA STATE
             LDAA #0
	     STAA ZERO_FLAG
	     
	     JSR STILL_ADDRESS
             LDAA #0B3H
	     STAA BUFFER
	     LDAA #2
	     STAA BUFFER+1
	     RTS


COPY_KEY_PRESSED
             
	     ; Save start address


             LDX DISPLAY
             STX START_ADDRESS

             LDAA #31
             STAA STATE
             LDAA #0
	     STAA ZERO_FLAG
	     
	     JSR STILL_ADDRESS
             LDAA #08FH
	     STAA BUFFER
	     LDAA #2
	     STAA BUFFER+1
	     RTS



REL_KEY_PRESSED
             
	     ; Save start address


             LDX DISPLAY
             STX START_ADDRESS

             LDAA #6
             STAA STATE
             LDAA #0
	     STAA ZERO_FLAG
	     
	     JSR STILL_ADDRESS
	     LDAA #0B3H
	     STAA BUFFER
	     LDAA #2
	     STAA BUFFER+1
	     RTS
    

SEND_INC1   ; Save start address


             LDX DISPLAY
             STX START_ADDRESS

             LDAA #8
             STAA STATE
             LDAA #0
	     STAA ZERO_FLAG
	     
	     JSR STILL_ADDRESS
	     LDAA #08FH
	     STAA BUFFER
	     LDAA #2
	     STAA BUFFER+1
	     RTS







; DECREMENT CURRENT ADDRESS BY ONE
;

KEY_DEC     LDAA STATE
            CMPA #20
            BNE SKIP_DEC1

            DEC DEMO_NO
            LDAA DEMO_NO
            STAA DEMO_NO
            CMPA #0
            BGE SKIP_DEC2
            CLRA
            STAA DEMO_NO

SKIP_DEC2   JSR DATA_DISPLAY


            RTS


SKIP_DEC1



            LDAA #2
            STAA STATE     ; STAATE =2 FOR DATA MODE

	    LDAA #0
	    STAA ZERO_FLAG
            

            LDX DISPLAY
            DEX
            STX DISPLAY
           ;  JSR READ_MEMORY
	     JSR STILL_DATA
	     RTS


; KEY GO WRITE USER REGISTERS TO STACK AND USE RTI TO JUMP TO USER PROGRAM
;

KEY_GO 
       LDAA STATE
       CMPA #32
       BEQ GO_STATE32   ; GO FOR COPYING DATA


       CMPA #6
       BEQ GO_STATE6

       CMPA #8
       BEQ GO_STATE8

       CMPA #10
       BEQ SHORT_GO_STATE10

       CMPA #20
       BNE SKIP_GO1

; EXECUTE KEY GO STATE 20 DEMO PROGRAMS

       LDAA DEMO_NO      ; CHECK SUB FUNCTION FOR STATE=20
       CMPA #4
       BNE DEMO2
       JSR DEMO_LCD
       RTS

DEMO2  CMPA #1
       BNE DEMO3
       JSR DEMO_LED
       RTS

DEMO3  CMPA #0
       BNE DEMO4
       JMP RUN_DOT

DEMO4  CMPA #2
       BNE DEMO5
       JMP BCD_COUNTING

DEMO5  CMPA #3
       BNE DEMO6
       JMP CLOCK_PGM

DEMO6



       RTS


GO_STATE32  JMP GO_COPY_MEMORY

            RTS


GO_STATE8   RTS




SHORT_GO_STATE10

           JSR GO_STATE10

           RTS




SKIP_GO1





        
        STS SAVE_SP   ; SAVE SYSTEM STACK
	              
; NOW SWITCH TO USER STACK

        LDS USER_SP   ; NOW LOAD WITH USER STACK
		
        LDAA DISPLAY+1
        PSHA
        LDAA DISPLAY
        PSHA
	LDAA USER_P
        TAP
        LDX USER_IX
        LDAB USER_B
	LDAA USER_A
        RTS



; KEY GO WITH RELATIVE CALCULATION
; FIND OFFSET BYTE

GO_STATE6


        LDX DISPLAY
        STX DESTINATION

; NOW COMPUTE OFFSET_BYTE = DESTINATION - START_ADDRESS

; THE REAL PC WILL BE NEXT INTSRUCTION ADDRESS (+2 FROM BRANCH INSTRUCTION)


        LDX START_ADDRESS
        INX
        INX
        STX TEMP16        ; SAVE CURRENT PC TO TEMP16



        LDAA DESTINATION+1
        SUBA TEMP16+1
        STAA OFFSET_BYTE+1

        LDAA DESTINATION
        SBCA TEMP16
        STAA OFFSET_BYTE



; CHECK IF THE OFFSET BYTE WAS BETWEEN -128 (FF80) TO +127 (007F)
; IF BIT 7 OF THE OFFSET BYTE IS 0, THE HIGH BYTE MUST BE ZERO
; IF BIT 7 OF THE OFFSET BYTE IS 1, THE HIGH BYTE MUST BE FF
; OTHERWISE, THE OFFSET BYTE WAS OUT OF RANGE, SHOW ERROR THEN

        LDAA OFFSET_BYTE+1
        ANDA #80H
	BEQ CHK_OFFSET_HIGH

; CHECK HIGH BYTE MUST BE FF (-1)
        
        LDAA OFFSET_BYTE
        CMPA #0FFH
	BNE OUT_OFF_RANGE

	JMP IN_RANGE

CHK_OFFSET_HIGH
        LDAA OFFSET_BYTE
	BNE OUT_OFF_RANGE

; STORE OFFSET TO THE 2ND BYTE OF BRANCH INSTRUCTION

IN_RANGE LDX START_ADDRESS
         INX

        LDAA OFFSET_BYTE+1
        STAA 0,X

        STX DISPLAY
       
	JSR STILL_DATA

	LDAA #2
        STAA STATE
	RTS

OUT_OFF_RANGE

        LDAA #2
	STAA BUFFER+5
	LDAA #8FH
	STAA BUFFER+4
	LDAA #3
	STAA BUFFER+3
	LDAA #3
	STAA BUFFER+2
	LDAA #0
	STAA BUFFER+1
	STAA BUFFER
	
	LDAA #2
        STAA STATE
	
	RTS





; SERVICE KEY GO FOR COPY KEY

GO_COPY_MEMORY

        LDX DISPLAY
        STX DESTINATION

COPY1
        LDX START_ADDRESS
        LDAA 0,X
        LDX DESTINATION
        STAA 0,X


        LDX DESTINATION
        INX
        STX DESTINATION


        LDX START_ADDRESS
        INX
        STX START_ADDRESS


        CPX END_ADDRESS

        BNE COPY1

; STORE LAST BYTE AS WELL

        LDX START_ADDRESS
        LDAA 0,X
        LDX DESTINATION
        STAA 0,X



	JSR STILL_DATA

	LDAA #2
        STAA STATE
	RTS
















             
; INSERT ONE BYTE WITHIN 256 BYTES
; CURRENT LOCATION WILL BE DISPLAY+1


KEY_INS  LDX DISPLAY ; GET CURRENT DISPLAY ADDRESS
         INX
         STX DISPLAY

         LDAB #0

INSERT   LDAA 0FEH,X
         STAA 0FFH,X
         DEX

         DECB
         BNE INSERT


         LDAA #0

         LDX DISPLAY
         STAA 0,X

         JSR STILL_DATA

         RTS

; DELETE ONE BYTE AT CURRENT DISPLAY ADDRESS
; SHIFTED UP 256 BYTES

KEY_DEL  LDX DISPLAY ; GET CURRENT DISPLAY ADDRESS

         LDAB #0

DELETE   LDAA 1,X
         STAA 0,X
         INX

         DECB
         BNE DELETE


         JSR STILL_DATA

         RTS


; SINGLE STEP KEY
; ENABLE BREAK SIGNAL SO AT THE 8TH OF E CLOCK, THE NMI WILL PRODUCE

KEY_STEP

        STS SAVE_SP   ; SAVE SYSTEM STACK
	              
; NOW SWITCH TO USER STACK

        LDS USER_SP   ; NOW LOAD WITH USER STACK
		
        LDAA DISPLAY+1
        PSHA
        LDAA DISPLAY  ; PUSH PC
        PSHA

        LDAA USER_IX+1
        PSHA
                       ; PUSH IX
        LDAA USER_IX
        PSHA

        LDAA USER_A    ; PUSH A
        PSHA

        LDAA USER_B    ; PUSH B
        PSHA

        LDAA USER_P   ; PUSH CONDITION CODE REGISTER
        PSHA

        LDAB #$FF
        STAB PORT1    ; NOW ENABLE 74LS164


        RTI           ; 10 CYCLES
          



NMI_SERVICE

       ; STAA GPIO1

        LDAA #0BFH
        STAA PORT1    ; STOP BREAK SIGNAL

        BRA  SWI_SERVICE

       ; RTI


; SAVE CPU REGISTERS TO USER REGISTERS
;  SWI INSTRUCTION 3FH


SWI_SERVICE

     ;   POP CC
     ;   POP ACCB
     ;   POP ACCA
     ;   POP IXH
     ;   POP IXL
     ;   POP PCH
     ;   POP PCL

        PULA
        STAA USER_P  ; SAVE CONDITION CODE REGISTER

        PULA
        STAA USER_B

        PULA
        STAA USER_A

        PULA
        STAA USER_IX

        PULA
        STAA USER_IX+1
        PULA

        STAA USER_PC
        PULA
        STAA USER_PC+1


        
        STS USER_SP

        LDS SAVE_SP    ; RESTORE SYSTEM STACK AND GET BACK TO MONITOR

        JSR KEY_PC     ; DISPLAY CURRENT PC

        RTS

;--------------------------------------------------------------

KEY_REL      LDAA #5
             STAA STATE ; STATE = 5 FOR RELATIVE BYTE CALCULATION

             LDAA #0
	     STAA ZERO_FLAG
	     JSR STILL_ADDRESS
	     LDAA #0AEH
	     STAA BUFFER
	     LDAA #2
	     STAA BUFFER+1
	     RTS



KEY_DOWNLOAD_HEX
              
	      LDAA #0B3H    ; PRINT LOAD
	      STAA BUFFER+5
	      LDAA #85H
	      STAA BUFFER+5
	      LDAA #0A3H
	      STAA BUFFER+4
	      LDAA #3FH
	      STAA BUFFER+3
	      LDAA #0B3H
	      STAA BUFFER+2
	      LDAA #0
	      STAA BUFFER+1
	      STAA BUFFER

              LDAA #10
              STAA STATE

              JSR CLR_SCREEN
              LDX #DOWNLOAD
              JSR PSTR

              LDAA #$FF
              STAA MUTE   ; TURN OFF BEEP

	      RTS


GO_STATE10    LDAA #1
	      STAA GPIO1

              LDX #DOWNLOAD2
              JSR PSTR


              JSR GET_RECORD  ; GET INTEL HEX FILE

              LDAA _ERROR
              CMPA #0
              BNE FOUND_ERROR

              LDX #COMPLETE
              JSR PSTR
              BRA SKIP_ERROR

FOUND_ERROR   LDX #ERROR_FOUND
              JSR PSTR

SKIP_ERROR    
	      
	      LDAA #2
              STAA STATE
	      JSR STILL_DATA
	      
	      RTS



KEY_DEMO      LDAA #20   ; STATE 20 FOR KEY DEMO
              STAA STATE

              LDAA #1FH    ; PRINT Prg
	      STAA BUFFER+5
              LDAA #03H
              STAA BUFFER+4

              LDAA #0BEH
              STAA BUFFER+3
              LDAA #0
              STAA BUFFER+2

              LDAA DEMO_NO
              JSR DATA_DISPLAY
              RTS





KEY_MUTE      COM MUTE
              RTS



KEY_COPY      LDAA #30
              STAA STATE    ; STATE = 30

              LDAA #0
              STAA ZERO_FLAG

              JSR STILL_ADDRESS
              LDAA #0AEH
              STAA BUFFER
              LDAA #2
              STAA BUFFER+1
              RTS






;------------------- HEX KEY FOR ADDRESS -------------------

HEX_ADDR     LDAA ZERO_FLAG
             CMPA #0
	     BNE SHIFT_ADDRESS

	     LDAA #1
	     STAA ZERO_FLAG   
             LDAA #0
	     STAA DISPLAY
	     STAA DISPLAY+1

SHIFT_ADDRESS CLC
             ROL DISPLAY+1
             ROL DISPLAY

             CLC
             ROL DISPLAY+1
             ROL DISPLAY

	     CLC
             ROL DISPLAY+1
             ROL DISPLAY

	     CLC
             ROL DISPLAY+1
             ROL DISPLAY

             LDAA DISPLAY+1
             ORAA REG_C
             STAA DISPLAY+1

            ; JSR READ_MEMORY

	     JSR STILL_ADDRESS

	     RTS
;------------------------- HEX KEY FOR DATA MODE --------------------------


HEX_DATA     LDAA ZERO_FLAG
             CMPA #0
	     BNE SHIFT_DATA

	     LDAA #1
	     STAA ZERO_FLAG   
             
	     LDAA #0
             LDX  DISPLAY
             STAA 0,X

SHIFT_DATA   LDX  DISPLAY
             LDAA 0,X
             ASLA
             ASLA
             ASLA
             ASLA
             ORAA REG_C
             STAA 0,X

	    ; JSR READ_MEMORY
	     JSR STILL_DATA
	     RTS


;************************ HEX REGSITERS DISPLAY **************************

; DISPLAY USER REGSITERS

HEX_REG  LDAA REG_C
         CMPA #0
	 BNE CHK_REG1

	 LDAA USER_A
	; STAA GPIO1
	 JSR DATA_DISPLAY

         LDAA #3FH
	 STAA BUFFER+2
         LDAA #8DH        ; REGISTER ACCA
	 STAA BUFFER+3
         LDAA #8DH
	 STAA BUFFER+4
         LDAA #3FH
         STAA BUFFER+5
	 RTS

CHK_REG1 
         CMPA #1
	 BNE CHK_REG2

         LDAA USER_B
	; STAA GPIO1

	 JSR DATA_DISPLAY
         LDAA #0A7H
	 STAA BUFFER+2
         LDAA #8DH         ; REGISTER ACCB
	 STAA BUFFER+3
         LDAA #8DH
	 STAA BUFFER+4
         LDAA #3FH
         STAA BUFFER+5
	 RTS

CHK_REG2  CMPA #2
	 BNE CHK_REG3

         LDX USER_IX
	; STAA GPIO1

         STX HL

         JSR ADDRESS_DISPLAY

         LDAA #30H
         STAA BUFFER+1
         LDAA #26H        ; REGISTER IX
         STAA BUFFER
	 RTS


CHK_REG3 CMPA #3
	 BNE CHK_REG4

         LDX USER_SP
	; STAA GPIO1
         STX HL 

         JSR ADDRESS_DISPLAY
         LDAA #0AEH
         STAA BUFFER+1
         LDAA #1FH        ; REGISTER SP
         STAA BUFFER
	 RTS



CHK_REG4  CMPA #4
         BNE CHK_REG5

                         ; CONDITION CODE DISPLAY FOR HIGH NIBBLE 11HI

         LDAA USER_P
         ANDA #$10
         BNE  SHOW_BIT4

         LDAA #ZERO
         STAA BUFFER+2
         BRA  NEXT_BIT1

SHOW_BIT4 LDAA #ONE
         STAA BUFFER+2

NEXT_BIT1 LDAA USER_P

          ANDA #$20
          BNE  SHOW_BIT5

          LDAA #ZERO
          STAA BUFFER+3
          BRA NEXT_BIT2

SHOW_BIT5 LDAA #ONE
          STAA BUFFER+3

NEXT_BIT2 LDAA #ONE
          STAA BUFFER+4
          STAA BUFFER+5

          LDAA #8DH     ; STORE CH, CONDITION CODE HIGH NIBBLE
          STAA BUFFER+1
          LDAA #37H
          STAA BUFFER


          RTS


CHK_REG5  CMPA #5
         BNE CHK_REG6

                         ; CONDITION CODE DISPLAY FOR LOW NIBBLE NZVC

         LDAA USER_P
         ANDA #$80
         BNE  SHOW_BIT6

         LDAA #ZERO
         STAA BUFFER+5
         BRA  NEXT_BIT3

SHOW_BIT6 LDAA #ONE
         STAA BUFFER+5

NEXT_BIT3 LDAA USER_P
          ANDA #4
          BNE  SHOW_BIT7

          LDAA #ZERO
          STAA BUFFER+4
          BRA NEXT_BIT4

SHOW_BIT7 LDAA #ONE
          STAA BUFFER+4

NEXT_BIT4 LDAA USER_P
          ANDA #2
          BNE SHOW_BIT8

          LDAA #ZERO
          STAA BUFFER+3
          BRA  NEXT_BIT5

SHOW_BIT8 LDAA #ONE
          STAA BUFFER+3

NEXT_BIT5 LDAA USER_P
          ANDA #1
          BNE SHOW_BIT9

          LDAA #ZERO
          STAA BUFFER+2
          BRA NEXT_BIT6

SHOW_BIT9 LDAA #ONE
          STAA BUFFER+2

NEXT_BIT6
          LDAA #8DH
          STAA BUFFER+1
          LDAA #85H
          STAA BUFFER
          RTS


CHK_REG6  CMPA #6
          BNE CHK_REG7

          LDX #0
          LDX 0,X
          STX HL
          JSR ADDRESS_DISPLAY

          LDAA #0
          JSR DATA_DISPLAY
          RTS


CHK_REG7  CMPA #7
          BNE CHK_REG8

          LDX #2
          LDX 0,X
          STX HL
          JSR ADDRESS_DISPLAY

          LDAA #2
          JSR DATA_DISPLAY
          RTS


CHK_REG8  CMPA #8
          BNE CHK_REG9

          LDX #4
          LDX 0,X
          STX HL
          JSR ADDRESS_DISPLAY

          LDAA #4
          JSR DATA_DISPLAY
          RTS

CHK_REG9  CMPA #9
          BNE CHK_REGA

          LDX #6
          LDX 0,X
          STX HL
          JSR ADDRESS_DISPLAY

          LDAA #6
          JSR DATA_DISPLAY
          RTS

CHK_REGA  

          RTS










          RTS

















          RTS


;------------------------------------------------------------

HEX_REL     JSR HEX_ADDR
            LDAA #0AEH
	    STAA BUFFER
	    LDAA #2
	    STAA BUFFER+1
	    RTS
            


HEX_REL6    JSR HEX_ADDR
            LDAA #0B3H
	    STAA BUFFER
	    LDAA #2
	    STAA BUFFER+1
	    RTS


HEX_COPY31            

            JSR HEX_ADDR
            LDAA #0AEH
	    STAA BUFFER
	    LDAA #2
	    STAA BUFFER+1
	    RTS


HEX_COPY32            

            JSR HEX_ADDR
            LDAA #08FH
	    STAA BUFFER
	    LDAA #2
	    STAA BUFFER+1
	    RTS

HEX_COPY33            

            JSR HEX_ADDR
            LDAA #0B3H
	    STAA BUFFER
	    LDAA #2
	    STAA BUFFER+1
	    RTS





HEX_SEND_FILE   RTS

HEX_SEND_FILE2  RTS







; SCAN DISPLAY AND KEYBOARD
; ENTRY: DISPLAY BUFFER IN PAGE 0
; EXIT: KEY = -1 NO KEY PRESSED
;       KEY >=0 KEY POSITION
; REGSITERS USED: X,A,Y

SCAN1	
        LDX #BUFFER
	
SCAN2   LDAA #0
	STAA REG_C
	
	LDAA #-1
	STAA KEY
	
	LDAA #1
	STAA REG_E
	
	LDAA #6
	STAA HL
				
;to the active column.
KCOL    LDAA REG_E	

        EORA #0FFH               ; COMPLEMENT IT

        ANDA #0BFH               ; MUST BE LOW FOR BREAK

	STAA DIGIT

        LDAA 0,X
	STAA SEG7

        ; automatic adjust for 1-3 segment display

        JSR AUTOBRIGHTNESS

;        LDAB #$30
;DELAY3  DECB
;        BNE DELAY3


	LDAA #0                 ; TURN LED OFF
	STAA SEG7

        LDAB #50
DELAY10 DECB
	BNE DELAY10
	

	LDAA #6
	STAA REG_B
	
	LDAA KIN
	
	STAA  REG_D

	
KROW	LSR  REG_D		;Rotate D 1 bit right, bit 0
				;of D will be rotated into
	BCS NOKEY			;carry flag.
	
	LDAA REG_C
	STAA KEY

NOKEY	INC REG_C		;Increase current key-code by 1.
	
	DEC REG_B
	BNE KROW
	
	INX
	
	LDAA REG_E
        ASLA
	STAA REG_E
		
	
	DEC  HL
	BNE  KCOL
	RTS


DEBOUNCE LDAB #200
DELAY4   DECB
	 BNE DELAY4
	 RTS

; ADJUST TIME ON IF EQUAL OR LESS THAN 3 BITS ON

AUTOBRIGHTNESS

         CLRB
         STAB BIT1_COUNTER

         LDAB #8

CHECK_BIT1 ROLA
           BCC _BIT1
         INC BIT1_COUNTER

_BIT1
         DECB
         BNE CHECK_BIT1

         LDAA BIT1_COUNTER

         CMPA #3     ; DIMMING FOR <=4 BITS THAT ON
         BGT NORMAL

         LDAB #3
DELAY20  DECB
         BNE DELAY20
         RTS


NORMAL


        LDAB #$30    ; tested with 20h 30
DELAY3  DECB
        BNE DELAY3
        RTS









;--------------------------------------------------------------------

SCANKEY JSR SCAN1
        LDAA KEY
        CMPA #-1
	BEQ KEY_RELEASED

	LDAA PORT0
        ANDA #40H
        BEQ SKIP_DISPLAY5

        JSR DEBOUNCE
        BRA SCANKEY

SKIP_DISPLAY5


; IF REPEAT KEY WAS PRESSED, SLOW DOWN IT
          LDAA #20
          STAA REPDELAY

DISPLAY4  JSR SCAN1
	  DEC REPDELAY
	  BNE DISPLAY4


          LDX #0         ; THEN REPEAT KEY PRESS        
          STX INVALID    ; RESET INVALID FLAG 
KEY_RELEASED

	JSR DEBOUNCE

UNTIL_PRESS
	
	JSR SCAN1
        LDAA KEY
        CMPA #-1
	BEQ UNTIL_PRESS

	JSR DEBOUNCE

	JSR SCAN1

	LDAA KEY
        LDX  #KEYTAB

        STX   TEMP16

        ADDA TEMP16+1
        STAA TEMP16+1

        LDAA #0
        ADCA TEMP16
        STAA TEMP16

        LDX TEMP16

        LDAA  0,X          ; OPEN TABLE
		
    ;    STAA GPIO1       ; TEST NOW A IS INTERNAL CODE 

        RTS


MAIN    JSR SCANKEY        ; scan display and keypad

        JSR KEYEXE         ; execute key that pressed

        JSR BEEP           ; beep/no beep after key executed

        BRA MAIN           ; repeat forever


;---------------------------------------------------------
; BEEP WHEN KEY PRESSED
;
; CALIBRATED TO 523Hz
; NEW FREQUENCY 673Hz, TESTED 670Hz

BEEP     LDAA PORT0    
         ANDA #40H    
	 BEQ NO_BEEP    ; CHECK IF REPEAT KEY IS PRESSED, THEN NO BEEP

         LDAA MUTE
         CMPA #0
         BEQ BEEPON
         RTS           ; IF MUTE=1 THEN NO BEEP



BEEPON   LDX #35h      ;    BEEP_PERIOD

BEEP2    LDAA #3FH
	 STAA PORT1
	 JSR BEEP_DELAY
	 LDAA #0BFH
	 STAA PORT1
	 JSR BEEP_DELAY

	 DEX
	 BNE BEEP2

NO_BEEP     

         RTS





BEEP_DELAY LDAB #52H  ;  #78H   ; #09BH CALIBRATED 524Hz
BEEP_LOOP DECB
          BNE BEEP_LOOP
	  RTS




; TEST CODE


TEST      INCA 
          STAA GPIO1
          BSR DELAY_LED
          BRA TEST

DELAY_LED LDX #2000
DELAY_LED1 DEX
          BNE DELAY_LED1
          RTS


; TEST BEEP

BEEP3    LDAA #3FH
	 STAA PORT1
         BSR BEEP_DELAY1
	 LDAA #0BFH
	 STAA PORT1
         BSR BEEP_DELAY1
         BNE BEEP3
         BRA BEEP3


BEEP_DELAY1 LDAB #0A0H      ; 
BEEP_LOOP1 DECB
          BNE BEEP_LOOP1
	  RTS




; CLEAR DISPLAY

CLR_SCREEN LDX #50

CLR_SCREEN1 STX TEMP16

         LDAA #13
         JSR SEND_BYTE
         LDAA #10
         JSR SEND_BYTE

         LDX TEMP16
         DEX
         BNE CLR_SCREEN1
         RTS



; PRINT STRING TO TERMINAL USING 2400 UART
; ENTRY: IX POINTED TO STRING 

PSTR     LDAA 0,X
         BNE SEND_STRING

         RTS

SEND_STRING

         STX IX2

         JSR SEND_BYTE

         LDX IX2
         INX
         BRA PSTR











;-------------------- HARDWARE DRIVERS-------------------------
; TEXT MODE LCD DRIVERS

; wait until LCD ready bit set


LcdReady         PSHA
ready            LDAA command_read
                 ANDA #BUSY
                 BNE ready   ; loop if busy flag = 1
                 PULA
		 RTS
		

LCD_command_write 
                   JSR LcdReady
                   STAA command_write
		   RTS
                  

LCD_data_write  JSR LcdReady
                STAA data_write
                RTS


clr_screen       JSR LcdReady
                 LDAA #1
		 JSR LCD_command_write
                 RTS

InitLcd          LDAA #38H
                 JSR LCD_command_write
                 LDAA #0CH
	         JSR LCD_command_write
                 JSR clr_screen
                 LDAA #0
                 LDAB #0
                 JSR goto_xy
                 RTS
		

; goto_xy(x,y)
; entry: A = x position
;        B = y position

goto_xy          CMPB #0
		 BNE case1
                 ADDA #80H
                 JSR LCD_command_write
		 RTS
                 
case1            CMPB #1
                 BNE case2
                 ADDA #0C0H
		 JSR LCD_command_write
		 RTS
                 
case2           RTS



; write ASCII code to LCD at current position
; entry: A

putch_lcd       JSR LCD_data_write
                RTS




; print strings on the LCD
; entry: IX pointed to string


pstring         LDAA 0,X
                BNE PSTRING1
                RTS

PSTRING1        STX IX2
                JSR putch_lcd
                LDX IX2
                INX
                BRA pstring


; DEMO LCD 20X2 BIG LETTERS LCD

DEMO_LCD        JSR InitLcd

                LDX #TEXT1
                JSR pstring

                LDAA #0
                LDAB #1
                JSR goto_xy
                LDX #TEXT2
                JSR pstring


                RTS



; BINARY COUNTING  #1

DEMO_LED    LDAA #0
	 
DEMOLOOP STAA GPIO1
         BSR DEMODELAY
         ADDA #1
         BRA DEMOLOOP


DEMODELAY    LDX #0000
DEMODELAY1   DEX
         BNE DEMODELAY1
         RTS


; RUNNING DOT LED  PRM #0

RUN_DOT  LDAA #1

RUN_DOT1 STAA GPIO1
         BSR DEMODELAY
         ROLA
         BRA RUN_DOT1


; BCD COUNTING  #2

BCD_COUNTING LDAA #0

BCD_COUNT1   STAA GPIO1
             BSR DEMODELAY
             ADDA #1
             DAA
             BRA BCD_COUNT1




; UPDATE CLOCK VARIABLES
; ENTER EVERY 10ms FROM IRQ INTERRUPT

SERVICE_IRQ


             LDAA SEC100
             ADDA #1
             STAA SEC100
             CMPA #100
             BNE  EXIT_CLOCK

             CLRA
             STAA SEC100

             LDAA SEC
             ADDA #1
             DAA
             STAA SEC
             CMPA #60H
             BNE EXIT_CLOCK

             CLRA
             STAA SEC

             LDAA MIN
             ADDA #1
             DAA
             STAA MIN
             CMPA #60H
             BNE EXIT_CLOCK
             CLRA
             STAA MIN

             LDAA HOUR
             ADDA #1
             STAA HOUR
             CMPA #24H
             BNE EXIT_CLOCK

             CLRA
             STAA HOUR

EXIT_CLOCK

             RTI


; CLOCK PROGRAM #3 TEST 10ms TICK MAKING CLOCK DISPLAY


CLOCK_PGM  LDAA #7EH    ; INSERT HEX CODE FOR JMP SERVICE_IRQ
           STAA $F8

           LDAA #SERVICE_IRQ>>8
           STAA $F9
           LDAA #SERVICE_IRQ&$FF
           STAA $FA

           CLRA
           STAA SEC100
           STAA SEC
           STAA MIN
           STAA HOUR
           STAA RUNSTOP


            CLI       ; ENABLE IRQ

DISPLAY_CLOCK


          LDAA SEC100
          JSR DATA_DISPLAY

          LDAA SEC
          STAA HL+1
          LDAA MIN
          STAA HL
          JSR ADDRESS_DISPLAY

          LDAA BUFFER+2
          ORAA #$40
          STAA BUFFER+2

          LDAA BUFFER+4
          ORAA #$40
          STAA BUFFER+4



          JSR SCAN1

          LDAA KEY
          CMPA #-1
          BEQ SKIP_SHOW_KEY

          CMPA #21H
          BNE SKIP_SHOW_KEY

          CLRA
          STAA SEC100
          STAA SEC
          STAA MIN
          STAA HOUR

       ;   STAA GPIO1

SKIP_SHOW_KEY

          BRA DISPLAY_CLOCK



; CHECK KEY PRESSED
; +    CODE 21H
; ADDR CODE 1BH
; GO   CODE 16H


DISPLAY_START_MSG

          LDX #START_MSG+6
          STX TEMP16


          LDAA #6
          STAA K

DISPLAY_MSG1

          LDAA #$20

          STAA J


DISPLAY_START1

          LDX TEMP16
          JSR SCAN2

          DEC J
          BNE DISPLAY_START1

          LDX TEMP16
          DEX
          STX TEMP16

          DEC K
          BNE DISPLAY_MSG1

          RTS



















;ssssssssssssssssssssssssss STRINGS CONSTANT sssssssssssssssssssssssssss
;

TEXT1           .BYTE "  Motorola 6802",0
TEXT2           .BYTE "Microprocessor Kit",0

TEXT3           .BYTE 13,10,"6802 MICROPROCESSOR KIT V1.0",0





DOWNLOAD .BYTE 13,10,"Press key GO",0
DOWNLOAD2 .BYTE 13,10,"Click File>Send File>..",0
COMPLETE .BYTE 13,10,"No error..",0
ERROR_FOUND .BYTE 13,10,"Checksum error!",0

START_MSG .BYTE 0
          .BYTE 0
          .BYTE 9BH
          .BYTE 0BDH
          .BYTE 0BFH
	  .BYTE 0AFH
          .BYTE 0
	  .BYTE 0
	  .BYTE 0
	  .BYTE 0
	  .BYTE 0
          .BYTE 0


SEGTAB	.BYTE	0BDH		;'0'
	.BYTE	030H		;'1'
	.BYTE	09BH		;'2'
	.BYTE	0BAH		;'3'
	.BYTE	036H		;'4'
	.BYTE	0AEH		;'5'
	.BYTE	0AFH		;'6'
	.BYTE	038H		;'7'
	.BYTE	0BFH		;'8'
	.BYTE	0BEH		;'9'
	.BYTE	03FH		;'A'
	.BYTE	0A7H		;'B'
	.BYTE	08DH		;'C'
	.BYTE	0B3H		;'D'
	.BYTE	08FH		;'E'
	.BYTE	00FH		;'F'



; Key-posistion-code to key-internal-code conversion table.

KEYTAB:
K0	.BYTE	03H	;HEX_3
K1	.BYTE	07H	;HEX_7
K2	.BYTE	0BH	;HEX_B
K3	.BYTE	0FH	;HEX_F
K4	.BYTE	20H	;NOT USED
K5	.BYTE	21H	;NOT USED
K6	.BYTE	02H	;HEX_2
K7	.BYTE	06H	;HEX_6
K8	.BYTE	0AH	;HEX_A
K9	.BYTE	0EH	;HEX_E
K0A	.BYTE	22H	;NOT USED
K0B	.BYTE	23H	;NOT USED
K0C	.BYTE	01H	;HEX_1
K0D	.BYTE	05H	;HEX_5
K0E	.BYTE	09H	;HEX_9
K0F	.BYTE	0DH	;HEX_D
K10	.BYTE	13H	;STEP
K11	.BYTE	1FH	;TAPERD
K12	.BYTE	00H	;HEX_0
K13	.BYTE	04H	;HEX_4
K14	.BYTE	08H	;HEX_8
K15	.BYTE	0CH	;HEX_C
K16	.BYTE	12H	;GO
K17	.BYTE	1EH	;TAPEWR
K18	.BYTE	1AH	;CBR
K19	.BYTE	18H	;PC
K1A	.BYTE	1BH	;REG
K1B	.BYTE	19H	;ADDR
K1C	.BYTE	17H	;DEL
K1D	.BYTE	1DH	;RELA
K1E	.BYTE	15H	;SBR
K1F	.BYTE	11H	;-
K20	.BYTE	14H	;DATA
K21	.BYTE	10H	;+
K22	.BYTE	16H	;INS
K23	.BYTE	1CH	;MOVE	



	     ; VECTOR NMI,RESET AND IRQ


          .ORG 0FFF8H

          .BYTE 0,0F8H ; RELOCATE IRQ TO RAM VECTOR AT 00F8H


          .ORG 0FFFAH     ; SWI VECTOR

          .BYTE SWI_SERVICE>>8,SWI_SERVICE&$FF


          .ORG 0FFFCH     ; NMI VECTOR

          .BYTE NMI_SERVICE>>8,NMI_SERVICE&$FF


          .ORG 0FFFEH

          .BYTE $C0,00   ; RESTART




	  .END



