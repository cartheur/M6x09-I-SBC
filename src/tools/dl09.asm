* Motorola s record downloading subrouitne

* S1 14 0200 8601B780008D034920F8CE07D00926FD39 30

* S1 0A 0218 CE13880926FD39 0D
 
* S9 03 0000 FC

           org $2000

GET_S_RECORD LDA #0
	   STA _ERROR



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

	   LDA #0	
	   STA BCC
	 
	   JSR GET_HEX
           STA REG_C     ; GET NUMBER OF pairs
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STA HL

           DEC REG_C
	   
	   JSR ADD_BCC

	   JSR GET_HEX
           STA HL+1        ; GET LOAD ADDRESS

           DEC REG_C

	   JSR ADD_BCC

           DEC REG_C        ; BYTE COUNT-1 FOR BCC

           BRA DATA_S_RECORD
	   
END_OF_RECORD

           JSR CIN
           CMPA #0DH         ; END OF LINE 0D,0A
           BNE END_OF_RECORD
	   
	   STA GPIO1
	   
	   LDA _ERROR
           CMPA #1
           BNE NOERROR2

* SHOW ERROR ON LED
*          JSR OUT_OFF_RANGE
	   
	   STA GPIO1

NOERROR2   
           RTS


DATA_S_RECORD

	   JSR GET_HEX
           LDX  HL
           STA 0,X  ; WRITE TO MEMORY
	   
	   JSR ADD_BCC

	   STA GPIO1
	   
           INC ,X
           STX HL
	   
	   DEC REG_C
           BNE DATA_S_RECORD ; UNTIL C=0

           LDA BCC
           EORA #0FFH    ; ONE'S COMPLEMENT
	   STA BCC
	   
	   
	   JSR GET_HEX	   ; GET BYTE CHECK SUM
	   
           CMPA BCC      ; COMPARE WITH BYTE CHECK SUM
           BEQ SKIP21
	  
	   LDA #1
	   STA _ERROR    ; ERROR FLAG =1
	   
	   
SKIP21
	   
           JMP GET_S_RECORD1     ; NEXT LINE 


