
#ifdef AS9
#asm

ADR1:  RMB 2
ADR2:  RMB 2
ADR3:  RMB 1
ADR31: RMB 3

 
   
   ORG  $fffe
   FDB  $c000

   org $fff8
*   fdb irq_serv
   fdb $7ff0       use ram vector
	
   org $fffc
   fdb $7ff3        nmi vector

   org $fff6
   fdb $7ff6        firq vector

   org $fffa
   fdb swi_serv

   ORG  $c000
   lds  #$7ff0

   lda #$7e        store jmp instruction 
   sta $7ff0       irq vector
   ldx #irq_serv
   stx $7ff1

   lda #$3b        store rti instruction
   sta $7ff3       must be modified when testing
   sta $7ff6       with ram vector

   ldx #0
   stx $7ff4
   stx $7ff7


   jmp  main

irq_serv
   
   inc tick
   rti

swi_serv
   
   PULS A
   STA USER_P
   PULS A
   STA USER_A
   PULS A
   STA USER_B
   PULS A
   STA USER_DP
   PULS X
   STX USER_X
   PULS X
   STX USER_Y
   PULS X
   STX USER_U
   PULS X
   STX USER_PC
   stx save_PC
   LDS SAVE_SP
   JSR key_PC
   rts


*
* 16 bit division
*
*
* D=X/D
*
ccdiv: CLR ADR31
 STX ADR1
 STD ADR2
ccd1: BGT ccd2
 COM ADR31
 COMA
 COMB
 ADDD #1
 STD ADR2
ccd2: LDD ADR1
 CMPD #0
 BGT ccd3
 COM ADR31
 COMA
 COMB
 ADDD #1
 STD ADR1
ccd3: LDA #16
 STA ADR3
 CLRA
 CLRB
DIVD:
 ASL ADR1+1
 ROL ADR1
 ROLB
 ROLA
 CMPD ADR2
 BLO NOSUB
 SUBD ADR2
 INC ADR1+1
NOSUB: DEC ADR3
 BNE DIVD
 TFR D,X
 LDD ADR1
 TST ADR31
 BEQ ccd4
 COMA
 COMB
 ADDD #1
ccd4: RTS

*
* 16 bit multiplication
*

ccmult: STX ADR1
 STD ADR2
 CLR ADR3
 CLR ADR3+1
 LDA ADR1+1
 LDB ADR2+1
 MUL
 STD ADR3+2
 LDA ADR1
 LDB ADR2+1
 MUL
 ADDD ADR3+1
 STD ADR3+1
 LDA ADR1+1
 LDB ADR2
 MUL
 ADDD ADR3+1
 STD ADR3+1
 BCC NOCARRY
 INC ADR3
NOCARRY: LDA ADR1
 LDB ADR2
 MUL
 ADDD ADR3
 TFR D,X
 LDD ADR3+2
 RTS


*
*  switch statement
*
* D = switch value
* S = switch table
*     FDB addr1, value1
*     FDB addr2, value2
*     ...
*     FDB 0
*     [JMP DEFAULT]
*     continuation
*
ccswitch: PULS X get stack adr
SWLOOP: LDY ,X++ get address
        CMPY #0 if 0
        BEQ SWEND then it is the default
        CMPD ,X++ else, if it is not the switch value
        BNE SWLOOP try next one
        JMP ,Y else we found it
SWEND:  JMP ,X default exit

  
#endasm
#else
#asm
   .globl  main
   .globl  ccdi
   .globl  ccmult
   .globl  ccswitch

   .area   RESET    (ABS,OVR)
   .org    0hfffe       ; reset vector
   .dw     0hc000

   .area   RAMDATA  (REL,CON)

   .area   ROMCODE  (REL,CON)
   lds     #0h7000
   jmp     main
#endasm
#endif
