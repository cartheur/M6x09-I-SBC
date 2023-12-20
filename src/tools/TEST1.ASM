
* small-c V2.3
       ORG $7000

* .global i
i: 
 RMB 2

* .global j
j: 
 RMB 2

* .global n
n: 
 RMB 1

* .global k
k: 
 RMB 1

* .global u
u: 
 RMB 1

* .global q
q: 
 RMB 1

* .global o
o: 
 RMB 1

* .global key
key: 
 RMB 1

* .global x
x: 
 RMB 1

* .global hit
hit: 
 RMB 1

* .global positive
positive: 
 RMB 1

* .global flag
flag: 
 RMB 1

* .global tick
tick: 
 RMB 1

* .global bcc
bcc: 
 RMB 1

* .global save_bcc
save_bcc: 
 RMB 1

* .global bcc_erro
bcc_erro: 
 RMB 1

* .global temp
temp: 
 RMB 2

* .global temp16
temp16: 
 RMB 2

* .global PC
PC: 
 RMB 2

* .global save_PC
save_PC: 
 RMB 2

* .global num
num: 
 RMB 2

* .global start
start: 
 RMB 2

* .global end
end: 
 RMB 2

* .global desti
desti: 
 RMB 2

* .global t
t: 
 RMB 2

* .global state
state: 
 RMB 1

* .global USER_PC
USER_PC: 
 RMB 2

* .global USER_U
USER_U: 
 RMB 2

* .global USER_X
USER_X: 
 RMB 2

* .global SAVE_SP
SAVE_SP: 
 RMB 2

* .global USER_Y
USER_Y: 
 RMB 2

* .global USER_A
USER_A: 
 RMB 1

* .global USER_B
USER_B: 
 RMB 1

* .global USER_P
USER_P: 
 RMB 1

* .global USER_DP
USER_DP: 
 RMB 1

* .global timeout
timeout: 
 RMB 2

* .global buffer
buffer: 
 RMB 6

* .global gpio1
gpio1: 
 FDB 0

* .global port2
port2: 
 FDB 0

* .global port1
port1: 
 FDB 0

* .global port0
port0: 
 FDB 0

* .global dptr
dptr: 
 FDB 0

* .global dptr2
dptr2: 
 FDB 0
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

*  .area  CONST  (REL,CON)

* .global convert
convert: 
 FCB 189,48,155,186,54,174,175,56,191,190
 FCB 63,167,141,179,143,15

* .global cold_msg
cold_msg: 
 FCB 0,0,0,0,0,0,174,191,189,190
 FCB 0,0

*  .area  ROMCODE  (REL,CON)

* .module LcdReady

* .global LcdReady
LcdReady: 
 ldd  #0
 std  timeout
 ldd  #-28670
 std  dptr
cc2:  
 ldd  dptr
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #128
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc4 ;_  instruction flagged for non optimize
 ldd  timeout
 pshs d
 ldd  #500
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc4 ;_  instruction flagged for non optimize
 ldd  #1
cc4:  
 cmpd #0
 lbeq cc3
 ldd  timeout
 addd #1
 std  timeout
 jmp cc2
cc3:  
 rts

* .global clr_scre
clr_scre: 
 jsr LcdReady
 ldd  #-28672
 std  dptr
 ldd  dptr
 pshs d
 ldd  #1
 stb  [,s++]
 rts

* .global goto_xy
goto_xy: 
 jsr LcdReady
 ldd  #-28672
 std  dptr
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 jmp cc7
cc8:  
 ldd  dptr
 pshs d
 ldd  #128
 pshs d
 leay 8,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 stb  [,s++]
 jmp cc6
cc9:  
 ldd  dptr
 pshs d
 ldd  #192
 pshs d
 leay 8,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 stb  [,s++]
 jmp cc6
cc10:  
 ldd  dptr
 pshs d
 ldd  #148
 pshs d
 leay 8,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 stb  [,s++]
 jmp cc6
cc11:  
 ldd  dptr
 pshs d
 ldd  #212
 pshs d
 leay 8,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 stb  [,s++]
 jmp cc6
 jmp cc6
cc7:  
 jsr ccswitch
 FDB cc8,0
 FDB cc9,1
 FDB cc10,2
 FDB cc11,3
 FDB 0
cc6:  
 rts

* .global InitLcd
InitLcd: 
 jsr LcdReady
 ldd  #-28672
 std  dptr
 ldd  dptr
 pshs d
 ldd  #56
 stb  [,s++]
 jsr LcdReady
 ldd  #-28672
 std  dptr
 ldd  dptr
 pshs d
 ldd  #12
 stb  [,s++]
 jsr clr_scre
 ldd  #0
 pshs d
 ldd  #0
 pshs d
 jsr goto_xy
 leas 4,s
 ldd  #100
 pshs d
 jsr delay_ms
 leas 2,s
 rts

* .global PutLCD
PutLCD: 
 leas -1,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #0
 stb  [,s++]
cc14:  
 leay 3,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc13
 jmp cc15
cc12:  
 leay 0,s
 tfr  y,d
 pshs d
 pshs d
 ldb  [,s++]
 sex
 addd #1
 stb  [,s++]
 subd #1
 jmp cc14
cc15:  
 jsr LcdReady
 ldd  #-28671
 std  dptr
 ldd  dptr
 pshs d
 leay 5,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 jmp cc12
cc13:  
 leas 1,s
 rts

* .global putch_lc
putch_lc: 
 jsr LcdReady
 ldd  #-28671
 std  dptr
 ldd  dptr
 pshs d
 leay 5,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 rts

* .global key_code
key_code: 
 leas -1,s
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #22
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc16
 ldd  #0
 leas 1,s
 rts
cc16:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #33
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc17
 ldd  #1
 leas 1,s
 rts
cc17:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #27
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc18
 ldd  #2
 leas 1,s
 rts
cc18:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #21
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc19
 ldd  #3
 leas 1,s
 rts
cc19:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #28
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc20
 ldd  #4
 leas 1,s
 rts
cc20:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #32
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc21
 ldd  #5
 leas 1,s
 rts
cc21:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #26
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc22
 ldd  #6
 leas 1,s
 rts
cc22:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #20
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc23
 ldd  #7
 leas 1,s
 rts
cc23:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #34
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc24
 ldd  #8
 leas 1,s
 rts
cc24:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #31
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc25
 ldd  #9
 leas 1,s
 rts
cc25:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #25
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc26
 ldd  #10
 leas 1,s
 rts
cc26:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #19
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc27
 ldd  #11
 leas 1,s
 rts
cc27:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #3
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc28
 ldd  #12
 leas 1,s
 rts
cc28:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #30
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc29
 ldd  #13
 leas 1,s
 rts
cc29:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #24
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc30
 ldd  #14
 leas 1,s
 rts
cc30:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #18
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc31
 ldd  #15
 leas 1,s
 rts
cc31:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #12
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc32
 ldd  #16
 leas 1,s
 rts
cc32:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #13
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc33
 ldd  #17
 leas 1,s
 rts
cc33:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #14
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc34
 ldd  #18
 leas 1,s
 rts
cc34:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #15
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc35
 ldd  #19
 leas 1,s
 rts
cc35:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #6
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc36
 ldd  #20
 leas 1,s
 rts
cc36:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #7
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc37
 ldd  #21
 leas 1,s
 rts
cc37:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #8
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc38
 ldd  #22
 leas 1,s
 rts
cc38:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #9
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc39
 ldd  #23
 leas 1,s
 rts
cc39:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc40
 ldd  #24
 leas 1,s
 rts
cc40:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc41
 ldd  #25
 leas 1,s
 rts
cc41:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc42
 ldd  #26
 leas 1,s
 rts
cc42:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #36
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc43
 ldd  #27
 leas 1,s
 rts
cc43:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #35
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc44
 ldd  #28
 leas 1,s
 rts
cc44:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #29
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc45
 ldd  #29
 leas 1,s
 rts
cc45:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #23
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc46
 ldd  #30
 leas 1,s
 rts
cc46:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #16
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc47
 ldd  #31
 leas 1,s
 rts
cc47:  
 leas 1,s
 rts

* .global delay_nu
delay_nu: 
 ldd  #0
 std  temp
 ldd  #0
 std  temp
 rts

* .global delay_ms
delay_ms: 
 ldd  #0
 stb  n
cc50:  
 ldb  n
 sex
 pshs d
 leay 4,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc49
 jmp cc51
cc48:  
 ldb  n
 sex
 addd #1
 stb  n
 subd #1
 jmp cc50
cc51:  
 jmp cc48
 jmp cc48
cc49:  
 rts

* .global scan
scan: 
 leas -1,s
 ldd  #1
 stb  k
 ldd  #0
 stb  u
 ldd  #1
 coma
 comb
 addd #1
 stb  key
 ldd  #0
 stb  q
 ldd  #0
 std  i
cc54:  
 ldd  i
 pshs d
 ldd  #6
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc53
 jmp cc55
cc52:  
 ldd  i
 addd #1
 std  i
 subd #1
 jmp cc54
cc55:  
 ldd  port1
 pshs d
 ldb  k
 sex
 coma
 comb
 stb  [,s++]
 ldd  port2
 pshs d
 ldd  #buffer
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #48
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc57 ;_  instruction flagged for non optimize
 ldd  #buffer
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #56
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc57 ;_  instruction flagged for non optimize
 ldd  #1
cc57:  
 cmpd #0
 lbeq cc58 ;_  instruction flagged for non optimize
 ldd  #buffer
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #112
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc58 ;_  instruction flagged for non optimize
 ldd  #1
cc58:  
 cmpd #0
 lbeq cc56
 ldd  #2
 pshs d
 jsr delay_ms
 leas 2,s
 jmp cc59
cc56:  
 jsr delay_nu
cc59:  
 ldd  port2
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #1
 pshs d
 jsr delay_ms
 leas 2,s
 ldd  port0
 pshs d
 ldb  [,s++]
 sex
 stb  o
 ldd  #0
 stb  n
cc62:  
 ldb  n
 sex
 pshs d
 ldd  #6
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc61
 jmp cc63
cc60:  
 ldb  n
 sex
 addd #1
 stb  n
 subd #1
 jmp cc62
cc63:  
 ldb  o
 sex
 pshs d
 ldd  #1
 anda ,s+
 andb ,s+
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc64
 ldb  q
 sex
 stb  key
 jmp cc65
cc64:  
 ldb  q
 sex
 addd #1
 stb  q
 subd #1
cc65:  
 ldb  o
 sex
 pshs d
 ldd  #1
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  o
 jmp cc60
cc61:  
 ldb  k
 sex
 pshs d
 ldd  #1
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 stb  k
 jmp cc52
cc53:  
 ldd  port0
 pshs d
 ldb  [,s++]
 sex
 stb  o
 ldb  o
 sex
 pshs d
 ldd  #64
 anda ,s+
 andb ,s+
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc66
 ldd  #36
 stb  key
cc66:  
 leay 0,s
 tfr  y,d
 pshs d
 ldb  key
 sex
 stb  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 leas 1,s
 rts

* .global dot_addr
dot_addr: 
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 rts

* .global dot_data
dot_data: 
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 coma
 comb
 anda ,s+
 andb ,s+
 stb  [,s++]
 rts

* .global hex4
hex4: 
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 std  temp16
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  temp16
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #temp16
 pshs d
 ldd  #4
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 std  temp16
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  temp16
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #temp16
 pshs d
 ldd  #4
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 std  temp16
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  temp16
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #temp16
 pshs d
 ldd  #4
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 std  temp16
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  temp16
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leas 6,s
 rts

* .global address_
address_: 
 ldd  PC
 std  temp16
 ldd  temp16
 pshs d
 jsr hex4
 leas 2,s
 rts

* .global data_dis
data_dis: 
 ldd  PC
 std  dptr
 ldd  dptr
 pshs d
 ldb  [,s++]
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 jsr dot_data
 rts

* .global read_mem
read_mem: 
 jsr address_
 jsr data_dis
 rts

* .global key_addr
key_addr: 
 ldd  #1
 stb  state
 jsr read_mem
 jsr dot_addr
 ldd  #0
 stb  hit
 rts

* .global key_data
key_data: 
 jsr read_mem
 jsr dot_data
 ldd  #0
 stb  hit
 ldd  #2
 stb  state
 rts

* .global key_plus
key_plus: 
 ldb  state
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc68
 ldb  state
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc68
 ldd  #0
 jmp cc69
cc68:  
 ldd  #1
cc69:  
 cmpd #0
 lbeq cc67
 ldd  PC
 addd #1
 std  PC
 subd #1
 jsr read_mem
 jsr key_data
cc67:  
 ldb  state
 sex
 pshs d
 ldd  #4
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc70
 ldd  num
 std  start
 ldd  #0
 stb  hit
 ldd  #1
 stb  positive
cc70:  
 ldb  state
 sex
 pshs d
 ldd  #5
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc71
 ldd  #6
 stb  state
 ldd  num
 std  start
 ldd  #0
 stb  hit
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #143
 stb  [,s++]
 rts
cc71:  
 ldb  state
 sex
 pshs d
 ldd  #6
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc72
 ldd  #7
 stb  state
 ldd  num
 std  end
 ldd  #0
 stb  hit
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #179
 stb  [,s++]
 ldd  end
 pshs d
 ldd  start
 cmpd ,s++
 bge  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc73
 jsr print_er
cc73:  
cc72:  
 rts

* .global key_minu
key_minu: 
 ldb  state
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 pshs d
 ldb  state
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 ora  ,s+
 orb  ,s+
 cmpd #0
 lbeq cc74
 ldd  PC
 subd #1
 std  PC
 addd #1
 jsr read_mem
 jsr key_data
cc74:  
 ldb  state
 sex
 pshs d
 ldd  #4
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc75
 ldd  num
 std  start
 ldd  #0
 stb  hit
 ldd  #0
 stb  positive
cc75:  
 rts

* .global data_hex
data_hex: 
 ldd  PC
 std  dptr
 ldd  dptr
 pshs d
 ldb  [,s++]
 sex
 stb  x
 ldb  hit
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc76
 ldd  #0
 stb  x
cc76:  
 ldd  #1
 stb  hit
 ldb  x
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 stb  x
 ldb  x
 sex
 pshs d
 ldb  key
 sex
 ora  ,s+
 orb  ,s+
 stb  x
 ldd  dptr
 pshs d
 ldb  x
 sex
 stb  [,s++]
 jsr read_mem
 jsr dot_data
 rts

* .global key_PC
key_PC: 
 ldd  save_PC
 std  PC
 jsr key_data
 rts

* .global hex_addr
hex_addr: 
 ldb  hit
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc77
 ldd  #0
 std  PC
cc77:  
 ldd  #1
 stb  hit
 ldd  #PC
 pshs d
 ldd  #4
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 std  PC
 ldd  #PC
 pshs d
 ldb  key
 sex
 ldx  [,s]
 pshs x
 ora  ,s+
 orb  ,s+
 std  PC
 jsr read_mem
 jsr dot_addr
 leas 4,s
 rts

* .global print_er
print_er: 
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #143
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #3
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #3
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #0
 stb  state
 rts

* .global key_go
key_go: 
 ldb  state
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc79
 ldb  state
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc79
 ldd  #0
 jmp cc80
cc79:  
 ldd  #1
cc80:  
 cmpd #0
 lbeq cc78
   STS SAVE_SP   
   LDU USER_U   
   LDD PC
   PSHS D
   LDA USER_P
   TFR A,CC
   LDA USER_DP
   TFR A,DP
   LDX USER_X
   LDY USER_Y
   LDB USER_B
   LDA USER_A
   RTS
cc78:  
 ldb  state
 sex
 pshs d
 ldd  #4
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc81
 ldd  num
 std  desti
 ldb  positive
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc82
 ldd  start
 pshs d
 ldd  desti
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 std  start
 jmp cc83
cc82:  
 ldd  start
 pshs d
 ldd  desti
 addd ,s++
 std  start
cc83:  
 ldd  start
 pshs d
 jsr hex4
 leas 2,s
 ldd  #0
 stb  hit
cc81:  
 ldb  state
 sex
 pshs d
 ldd  #7
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc84
 ldd  num
 std  desti
 ldd  end
 pshs d
 ldd  start
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 std  temp
 ldd  start
 std  dptr
 ldd  desti
 std  dptr2
 ldd  #0
 std  i
cc87:  
 ldd  i
 pshs d
 ldd  temp
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc86
 jmp cc88
cc85:  
 ldd  i
 addd #1
 std  i
 subd #1
 jmp cc87
cc88:  
 ldd  dptr2
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldd  dptr
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 jmp cc85
cc86:  
 ldd  desti
 std  PC
 jsr read_mem
 jsr dot_data
 ldd  #2
 stb  state
cc84:  
 rts

* .global key_reg
key_reg: 
 ldd  #buffer
 pshs d
 ldd  #7
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #6
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #3
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #143
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #173
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #3
 stb  state
 rts

* .global acca
acca: 
 ldb  USER_A
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #63
 stb  [,s++]
 rts

* .global accb
accb: 
 ldb  USER_B
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #167
 stb  [,s++]
 rts

* .global ab
ab: 
 ldb  USER_B
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  USER_A
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #63
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #167
 stb  [,s++]
 rts

* .global reg_x
reg_x: 
 ldd  USER_X
 std  temp16
 ldd  temp16
 pshs d
 jsr hex4
 leas 2,s
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #19
 stb  [,s++]
 rts

* .global reg_y
reg_y: 
 ldd  USER_Y
 std  temp16
 ldd  temp16
 pshs d
 jsr hex4
 leas 2,s
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #182
 stb  [,s++]
 rts

* .global reg_u
reg_u: 
 ldd  USER_U
 std  temp16
 ldd  temp16
 pshs d
 jsr hex4
 leas 2,s
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #181
 stb  [,s++]
 rts

* .global reg_s
reg_s: 
 ldd  SAVE_SP
 std  temp16
 ldd  temp16
 pshs d
 jsr hex4
 leas 2,s
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #174
 stb  [,s++]
 rts

* .global reg_dp
reg_dp: 
 ldb  USER_DP
 sex
 stb  n
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldb  n
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  n
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldb  n
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #179
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #31
 stb  [,s++]
 rts

* .global low_cc
low_cc: 
 ldb  USER_P
 sex
 stb  n
 ldb  n
 sex
 pshs d
 ldd  #1
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc89
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc90
cc89:  
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc90:  
 ldb  n
 sex
 pshs d
 ldd  #2
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc91
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc92
cc91:  
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc92:  
 ldb  n
 sex
 pshs d
 ldd  #4
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc93
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc94
cc93:  
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc94:  
 ldb  n
 sex
 pshs d
 ldd  #8
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc95
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc96
cc95:  
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc96:  
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #141
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #133
 stb  [,s++]
 rts

* .global hi_cc
hi_cc: 
 ldb  USER_P
 sex
 stb  n
 ldb  n
 sex
 pshs d
 ldd  #16
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc97
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc98
cc97:  
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc98:  
 ldb  n
 sex
 pshs d
 ldd  #32
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc99
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc100
cc99:  
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc100:  
 ldb  n
 sex
 pshs d
 ldd  #64
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc101
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc102
cc101:  
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc102:  
 ldb  n
 sex
 pshs d
 ldd  #128
 anda ,s+
 andb ,s+
 cmpd #0
 lbeq cc103
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #48
 stb  [,s++]
 jmp cc104
cc103:  
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
cc104:  
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #141
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #55
 stb  [,s++]
 rts

* .global reg_disp
reg_disp: 
 ldb  key
 sex
 jmp cc107
cc108:  
 jsr acca
 jmp cc106
cc109:  
 jsr accb
 jmp cc106
cc110:  
 jsr ab
 jmp cc106
cc111:  
 jsr reg_x
 jmp cc106
cc112:  
 jsr reg_y
 jmp cc106
cc113:  
 jsr reg_u
 jmp cc106
cc114:  
 jsr reg_s
 jmp cc106
cc115:  
 jsr reg_dp
 jmp cc106
cc116:  
 jsr low_cc
 jmp cc106
cc117:  
 jsr hi_cc
 jmp cc106
 jmp cc106
cc107:  
 jsr ccswitch
 FDB cc108,0
 FDB cc109,1
 FDB cc110,2
 FDB cc111,6
 FDB cc112,7
 FDB cc113,9
 FDB cc114,10
 FDB cc115,8
 FDB cc116,5
 FDB cc117,4
 FDB 0
cc106:  
 rts

* .global insert
insert: 
 ldb  state
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc119
 ldb  state
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc119
 ldd  #0
 jmp cc120
cc119:  
 ldd  #1
cc120:  
 cmpd #0
 lbeq cc118
 ldd  PC
 std  dptr
 ldd  #512
 std  j
cc123:  
 ldd  j
 pshs d
 ldd  #0
 cmpd ,s++
 blt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc122
 jmp cc124
cc121:  
 ldd  j
 subd #1
 std  j
 addd #1
 jmp cc123
cc124:  
 ldd  dptr
 pshs d
 ldd  j
 addd ,s++
 pshs d
 ldd  dptr
 pshs d
 ldd  j
 addd ,s++
 pshs d
 ldd  #1
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 jmp cc121
cc122:  
 ldd  dptr
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  PC
 addd #1
 std  PC
 subd #1
 jsr read_mem
 ldd  #2
 stb  state
cc118:  
 rts

* .global cut_byte
cut_byte: 
 ldb  state
 sex
 pshs d
 ldd  #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc126
 ldb  state
 sex
 pshs d
 ldd  #2
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbne cc126
 ldd  #0
 jmp cc127
cc126:  
 ldd  #1
cc127:  
 cmpd #0
 lbeq cc125
 ldd  PC
 std  dptr
 ldd  #0
 std  j
cc130:  
 ldd  j
 pshs d
 ldd  #512
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc129
 jmp cc131
cc128:  
 ldd  j
 addd #1
 std  j
 subd #1
 jmp cc130
cc131:  
 ldd  dptr
 pshs d
 ldd  j
 addd ,s++
 pshs d
 ldd  dptr
 pshs d
 ldd  j
 addd ,s++
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 jmp cc128
cc129:  
 jsr read_mem
 ldd  #2
 stb  state
cc125:  
 rts

* .global key_test
key_test: 
		andcc #$ef
 ldd  #0
 std  t
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
cc132:  
 ldd  #1
 cmpd #0
 lbeq cc133
cc134:  
 ldb  tick
 sex
 pshs d
 ldd  #100
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc135
 jsr scan
 jmp cc134
cc135:  
 ldd  #0
 stb  tick
 ldd  t
 pshs d
 jsr hex4
 leas 2,s
 ldd  gpio1
 pshs d
 ldd  t
 stb  [,s++]
 ldd  t
 addd #1
 std  t
 subd #1
 jmp cc132
cc133:  
 rts

* .global clear_bu
clear_bu: 
 ldd  #0
 std  i
cc138:  
 ldd  i
 pshs d
 ldd  #6
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc137
 jmp cc139
cc136:  
 ldd  i
 addd #1
 std  i
 subd #1
 jmp cc138
cc139:  
 ldd  #buffer
 pshs d
 ldd  i
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 jmp cc136
cc137:  
 rts

* .global key_cal
key_cal: 
 ldd  #4
 stb  state
 jsr clear_bu
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
 ldd  #0
 std  start
 ldd  #0
 std  desti
 ldd  #0
 stb  hit
 rts

* .global enter_nu
enter_nu: 
 ldb  hit
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc140
 ldd  #0
 std  num
cc140:  
 ldd  #1
 stb  hit
 ldd  #num
 pshs d
 ldd  #4
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 std  num
 ldd  #num
 pshs d
 ldb  key
 sex
 ldx  [,s]
 pshs x
 ora  ,s+
 orb  ,s+
 std  num
 ldd  num
 pshs d
 jsr hex4
 leas 2,s
 leas 4,s
 rts

* .global key_copy
key_copy: 
 ldd  #5
 stb  state
 ldd  #0
 stb  hit
 jsr clear_bu
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #189
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #174
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 rts

* .global key_exe
key_exe: 
 ldb  flag
 sex
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc141
 jsr beep
cc141:  
 ldb  key
 sex
 pshs d
 ldd  #15
 cmpd ,s++
 blt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc142
 ldb  key
 sex
 jmp cc145
cc146:  
 jsr key_addr
 jmp cc144
cc147:  
 jsr key_data
 jmp cc144
cc148:  
 jsr key_plus
 jmp cc144
cc149:  
 jsr key_minu
 jmp cc144
cc150:  
 jsr key_PC
 jmp cc144
cc151:  
 jsr key_go
 jmp cc144
cc152:  
 jsr key_reg
 jmp cc144
cc153:  
 jsr insert
 jmp cc144
cc154:  
 jsr cut_byte
 jmp cc144
cc155:  
 ldb  flag
 sex
 pshs d
 ldd  #1
 eora ,s+
 eorb ,s+
 stb  flag
 jmp cc144
cc156:  
 jsr key_test
 jmp cc144
cc157:  
 jsr key_cal
 jmp cc144
cc158:  
 jsr key_copy
 jmp cc144
cc159:  
 jsr key_dump
 jmp cc144
cc160:  
 jsr key_load
 jmp cc144
 jmp cc144
cc145:  
 jsr ccswitch
 FDB cc146,19
 FDB cc147,18
 FDB cc148,23
 FDB cc149,22
 FDB cc150,16
 FDB cc151,27
 FDB cc152,17
 FDB cc153,24
 FDB cc154,25
 FDB cc155,21
 FDB cc156,26
 FDB cc157,29
 FDB cc158,28
 FDB cc159,30
 FDB cc160,31
 FDB 0
cc144:  
 jmp cc161
cc142:  
 ldb  state
 sex
 jmp cc164
cc165:  
 jsr hex_addr
 jmp cc163
cc166:  
 jsr data_hex
 jmp cc163
cc167:  
 jsr reg_disp
 jmp cc163
cc168:  
 jsr enter_nu
 jmp cc163
cc169:  
 jsr enter_nu
 jmp cc163
cc170:  
 jsr enter_nu
 jmp cc163
cc171:  
 jsr enter_nu
 jmp cc163
 jmp cc163
cc164:  
 jsr ccswitch
 FDB cc165,1
 FDB cc166,2
 FDB cc167,3
 FDB cc168,4
 FDB cc169,5
 FDB cc170,6
 FDB cc171,7
 FDB 0
cc163:  
cc161:  
 rts

* .global delay_be
delay_be: 
 ldd  #0
 std  j
cc174:  
 ldd  j
 pshs d
 ldd  #2
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc173
 jmp cc175
cc172:  
 ldd  j
 addd #1
 std  j
 subd #1
 jmp cc174
cc175:  
 jmp cc172
 jmp cc172
cc173:  
 rts

* .global beep
beep: 
 leas -1,s
 ldd  port2
 pshs d
 ldd  #0
 stb  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #0
 stb  [,s++]
cc178:  
 leay 0,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #60
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc177
 jmp cc179
cc176:  
 leay 0,s
 tfr  y,d
 pshs d
 pshs d
 ldb  [,s++]
 sex
 addd #1
 stb  [,s++]
 subd #1
 jmp cc178
cc179:  
 ldd  port1
 pshs d
 ldd  #128
 coma
 comb
 stb  [,s++]
 jsr delay_be
 ldd  port1
 pshs d
 ldd  #255
 stb  [,s++]
 jsr delay_be
 jmp cc176
cc177:  
 leas 1,s
 rts

* .global scan1
scan1: 
cc180:  
 jsr scan
 pshs d
 ldd  #1
 coma
 comb
 addd #1
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc181
 jmp cc180
 jmp cc180
cc181:  
 ldd  #3
 pshs d
 jsr delay_ms
 leas 2,s
cc182:  
 jsr scan
 pshs d
 ldd  #1
 coma
 comb
 addd #1
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc183
 jmp cc182
 jmp cc182
cc183:  
 ldd  #3
 pshs d
 jsr delay_ms
 leas 2,s
 jsr scan
 stb  key
 ldb  key
 sex
 pshs d
 jsr key_code
 leas 2,s
 stb  key
 jsr key_exe
 rts

* .global initacia
initacia: 
 leas -5,s
 leay 2,s
 tfr  y,d
 pshs d
 ldd  #-24576
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #22
 stb  [,s++]
 leay 1,s
 tfr  y,d
 pshs d
 ldd  #3
 stb  [,s++]
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leay 4,s
 tfr  y,d
 pshs d
 leay 4,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leas 5,s
 rts

* .global putchar
putchar: 
 leas -2,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #-24576
 std  [,s++]
cc184:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #2
 anda ,s+
 andb ,s+
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc185
 jmp cc184
 jmp cc184
cc185:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 leay 7,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leas 2,s
 rts

* .global puts
puts: 
cc186:  
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldb  [,s++]
 sex
 cmpd #0
 lbeq cc187
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldb  [,s++]
 sex
 pshs d
 jsr putchar
 leas 2,s
 leay 2,s
 tfr  y,d
 pshs d
 pshs d
 ldd  [,s++]
 addd #1
 std  [,s++]
 subd #1
 jmp cc186
cc187:  
 rts

* .global getchar
getchar: 
 leas -3,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #-24576
 std  [,s++]
cc188:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #1
 anda ,s+
 andb ,s+
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc189
 jmp cc188
 jmp cc188
cc189:  
 leay 2,s
 tfr  y,d
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leay 2,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 leas 3,s
 rts

* .global newline
newline: 
 ldd  #10
 pshs d
 jsr putchar
 leas 2,s
 ldd  #13
 pshs d
 jsr putchar
 leas 2,s
 rts

* .global send_hex
send_hex: 
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #4
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 stb  k
 ldb  k
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 stb  k
 ldb  k
 sex
 pshs d
 ldd  #9
 cmpd ,s++
 blt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc190
 ldb  k
 sex
 pshs d
 ldd  #55
 addd ,s++
 pshs d
 jsr putchar
 leas 2,s
 jmp cc191
cc190:  
 ldb  k
 sex
 pshs d
 ldd  #48
 addd ,s++
 pshs d
 jsr putchar
 leas 2,s
cc191:  
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #15
 anda ,s+
 andb ,s+
 stb  k
 ldb  k
 sex
 pshs d
 ldd  #9
 cmpd ,s++
 blt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc192
 ldb  k
 sex
 pshs d
 ldd  #55
 addd ,s++
 pshs d
 jsr putchar
 leas 2,s
 jmp cc193
cc192:  
 ldb  k
 sex
 pshs d
 ldd  #48
 addd ,s++
 pshs d
 jsr putchar
 leas 2,s
cc193:  
 rts

* .global send_wor
send_wor: 
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #8
 decb
 blt  *+8
 lsr  ,s
 ror  1,s
 bra *-7
 puls d
 std  temp16
 ldd  temp16
 pshs d
 ldd  #255
 anda ,s+
 andb ,s+
 stb  k
 ldb  k
 sex
 pshs d
 jsr send_hex
 leas 2,s
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #255
 anda ,s+
 andb ,s+
 stb  k
 ldb  k
 sex
 pshs d
 jsr send_hex
 leas 2,s
 rts

* .global key_dump
key_dump: 
 leas -4,s
 ldd  PC
 std  dptr
 leay 2,s
 tfr  y,d
 pshs d
 ldd  #0
 std  [,s++]
cc196:  
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #16
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc195
 jmp cc197
cc194:  
 leay 2,s
 tfr  y,d
 pshs d
 pshs d
 ldd  [,s++]
 addd #1
 std  [,s++]
 subd #1
 jmp cc196
cc197:  
 jsr newline
 ldd  dptr
 pshs d
 jsr send_wor
 leas 2,s
 ldd  #58
 pshs d
 jsr putchar
 leas 2,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #0
 std  [,s++]
cc200:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #16
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc199
 jmp cc201
cc198:  
 leay 0,s
 tfr  y,d
 pshs d
 pshs d
 ldd  [,s++]
 addd #1
 std  [,s++]
 subd #1
 jmp cc200
cc201:  
 ldd  dptr
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 pshs d
 jsr send_hex
 leas 2,s
 ldd  #32
 pshs d
 jsr putchar
 leas 2,s
 jmp cc198
cc199:  
 ldd  #32
 pshs d
 jsr putchar
 leas 2,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #0
 std  [,s++]
cc204:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #16
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc203
 jmp cc205
cc202:  
 leay 0,s
 tfr  y,d
 pshs d
 pshs d
 ldd  [,s++]
 addd #1
 std  [,s++]
 subd #1
 jmp cc204
cc205:  
 ldd  dptr
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  q
 ldb  q
 sex
 pshs d
 ldd  #32
 cmpd ,s++
 ble  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc207 ;_  instruction flagged for non optimize
 ldb  q
 sex
 pshs d
 ldd  #128
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc207 ;_  instruction flagged for non optimize
 ldd  #1
cc207:  
 cmpd #0
 lbeq cc206
 ldb  q
 sex
 pshs d
 jsr putchar
 leas 2,s
 jmp cc208
cc206:  
 ldd  #46
 pshs d
 jsr putchar
 leas 2,s
cc208:  
 jmp cc202
cc203:  
 ldd  #dptr
 pshs d
 ldd  #16
 ldx  [,s]
 pshs x
 addd ,s++
 std  dptr
 leas 2,s
 jmp cc194
cc195:  
 jsr newline
 ldd  dptr
 std  PC
 jsr key_addr
 leas 4,s
 rts

* .global nibble2h
nibble2h: 
 leas -1,s
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #64
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc209
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #48
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 leas 1,s
 rts
cc209:  
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #55
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 leas 1,s
 rts
cc210:  
 leas 1,s
 rts

* .global gethex
gethex: 
 leas -2,s
 leay 1,s
 tfr  y,d
 pshs d
 jsr getchar2
 stb  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 jsr getchar2
 stb  [,s++]
 leay 1,s
 tfr  y,d
 pshs d
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 jsr nibble2h
 leas 2,s
 pshs d
 ldd  #4
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 stb  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 jsr nibble2h
 leas 2,s
 stb  [,s++]
 leay 1,s
 tfr  y,d
 pshs d
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 ora  ,s+
 orb  ,s+
 stb  [,s++]
 ldb  bcc
 sex
 pshs d
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 addd ,s++
 stb  bcc
 leay 1,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 leas 2,s
 rts

* .global get16bit
get16bit: 
 leas -2,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #0
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 jsr gethex
 ldx  [,s]
 pshs x
 ora  ,s+
 orb  ,s+
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #8
 ldx  [,s]
 pshs x
 decb
 blt  *+8
 asl  1,s
 rol  ,s
 bra  *-7
 puls d
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 jsr gethex
 ldx  [,s]
 pshs x
 ora  ,s+
 orb  ,s+
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 leas 2,s
 rts

* .global read_rec
read_rec: 
 leas -4,s
 ldd  #0
 stb  bcc
 leay 2,s
 tfr  y,d
 pshs d
 jsr gethex
 pshs d
 ldd  #3
 puls x
 pshs d
 tfr  x,d
 subd ,s++
 stb  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 jsr get16bit
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 std  dptr
 leay 3,s
 tfr  y,d
 pshs d
 ldd  #0
 stb  [,s++]
cc213:  
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 pshs d
 leay 4,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc212
 jmp cc214
cc211:  
 leay 3,s
 tfr  y,d
 pshs d
 pshs d
 ldb  [,s++]
 sex
 addd #1
 stb  [,s++]
 subd #1
 jmp cc213
cc214:  
 ldd  dptr
 pshs d
 leay 5,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 addd ,s++
 pshs d
 jsr gethex
 stb  [,s++]
 jmp cc211
cc212:  
 ldb  bcc
 sex
 coma
 comb
 stb  bcc
 ldd  gpio1
 pshs d
 ldb  bcc
 sex
 stb  [,s++]
 ldb  bcc
 sex
 stb  save_bcc
 ldb  save_bcc
 sex
 pshs d
 jsr gethex
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc215
 ldd  #1
 stb  bcc_erro
cc215:  
 leas 4,s
 rts

* .global get_s_re
get_s_re: 
 ldd  #0
 std  end
 ldd  #0
 stb  bcc_erro
cc216:  
 ldd  end
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc217
cc218:  
 jsr getchar2
 pshs d
 ldd  #83
 cmpd ,s++
 bne   *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc219
 jmp cc218
 jmp cc218
cc219:  
 jsr getchar2
 jmp cc222
cc223:  
 ldd  #0
 std  end
 jmp cc221
cc224:  
 jsr read_rec
 jmp cc221
cc225:  
 ldd  #1
 std  end
 jmp cc221
cc226:  
 ldd  #1
 std  end
 jmp cc221
 jmp cc221
cc222:  
 jsr ccswitch
 FDB cc223,48
 FDB cc224,49
 FDB cc225,56
 FDB cc226,57
 FDB 0
cc221:  
 jmp cc216
cc217:  
 jsr newline
 ldb  bcc_erro
 sex
 cmpd #0
 lbeq cc227
 ldd  #cc1+0
 pshs d
 jsr puts
 leas 2,s
 jmp cc228
cc227:  
 ldd  #cc1+18
 pshs d
 jsr puts
 leas 2,s
cc228:  
 jsr key_data
 rts
cc1:  
 FCB 99,104,101,99,107,32,115,117,109,32
 FCB 101,114,114,111,114,115,33,0,48,32
 FCB 101,114,114,111,114,46,46,46,0

* .global key_load
key_load: 
 jsr newline
 ldd  #cc229+0
 pshs d
 jsr puts
 leas 2,s
 jsr get_s_re
 rts
cc229:  
 FCB 76,111,97,100,32,77,111,116,111,114
 FCB 111,108,97,32,115,45,114,101,99,111
 FCB 114,100,0

* .global initreg
initreg: 
 ldd  #512
 std  PC
 ldd  #512
 std  save_PC
 ldd  #32512
 std  USER_U
	   TFR CC,A
	   STA USER_P
 ldd  #-32768
 std  gpio1
 ldd  #-32765
 std  port2
 ldd  #-32766
 std  port1
 ldd  #-32767
 std  port0
 rts

* .global wait1s
wait1s: 
		andcc #$ef
cc231:  
 ldb  tick
 sex
 pshs d
 ldd  #100
 cmpd ,s++
 bgt  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc232
 jmp cc231
cc232:  
 ldd  #0
 stb  tick
 rts

* .global getchar2
getchar2: 
 leas -3,s
 leay 0,s
 tfr  y,d
 pshs d
 ldd  #-24576
 std  [,s++]
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #22
 stb  [,s++]
cc233:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldb  [,s++]
 sex
 pshs d
 ldd  #1
 anda ,s+
 andb ,s+
 pshs d
 ldd  #0
 cmpd ,s++
 beq  *+7
 ldd  #0
 bra  *+5
 ldd  #1
 cmpd #0
 lbeq cc234
 jmp cc233
cc234:  
 leay 0,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #86
 stb  [,s++]
 leay 2,s
 tfr  y,d
 pshs d
 leay 2,s
 tfr  y,d
 pshs d
 ldd  [,s++]
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 leay 2,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 leas 3,s
 rts

* .global main
main: 
 jsr initreg
 ldd  gpio1
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  port2
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  port1
 pshs d
 ldd  #255
 stb  [,s++]
 ldd  #0
 stb  flag
 jsr initacia
 jsr newline
 ldd  #cc230+0
 pshs d
 jsr puts
 leas 2,s
 jsr InitLcd
 jsr InitLcd
 ldd  #cc230+29
 pshs d
 jsr PutLCD
 leas 2,s
 ldd  #0
 pshs d
 ldd  #1
 pshs d
 jsr goto_xy
 leas 4,s
 ldd  #cc230+49
 pshs d
 jsr PutLCD
 leas 2,s
 ldd  #buffer
 pshs d
 ldd  #5
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  #6
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #4
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  #8
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #3
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #2
 addd ,s++
 pshs d
 ldd  #convert
 pshs d
 ldd  #9
 addd ,s++
 pshs d
 ldb  [,s++]
 sex
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #1
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
 ldd  #buffer
 pshs d
 ldd  #0
 addd ,s++
 pshs d
 ldd  #0
 stb  [,s++]
cc235:  
 ldd  #1
 cmpd #0
 lbeq cc236
 jsr scan1
 jmp cc235
cc236:  
 rts
cc230:  
 FCB 54,56,48,57,32,77,73,67,82,79
 FCB 80,82,79,67,69,83,83,79,82,32
 FCB 75,73,84,32,50,48,49,55,0,54
 FCB 56,48,57,32,77,73,67,82,79,80
 FCB 82,79,67,69,83,83,79,82,0,51
 FCB 50,107,66,32,82,65,77,32,85,65
 FCB 82,84,32,76,67,68,0
  END
