
* small-c V2.3
   ORG  $fffe
   FDB  $c000
   org $fffa
   fdb swi_serv
   ORG  $c000
   lds  #$7fff
   jmp  main
;swi_serv
;   PULS A
;   STA USER_P
;   PULS A
;   STA USER_A
;   PULS A
;   STA USER_B
;   PULS A
;   STA USER_DP
;   PULS X
;   STX USER_X
;   PULS X
;   STX USER_Y
;   PULS X
;   STX USER_U
;   PULS X
;   STX USER_PC
;   stx save_PC
;   LDS SAVE_SP
;   JSR key_PC
;   rts
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
SWLOOP:   LDY ,X++ get address
          CMPY #0 if 0
          BEQ SWEND then it is the default
          CMPD ,X++ else, if it is not the switch value
          BNE SWLOOP try next one
          JMP ,Y else we found it
SWEND:    JMP ,X default exit

* .global n
n: 
 RMB 1

* .global x
x: 
 RMB 1

* .module main

* .global main
main: 
 ldb  n
 sex
 jmp cc4
cc5:  
 ldd  #1
 stb  x
 jmp cc3
cc6:  
 ldd  #2
 stb  x
 jmp cc3
cc7:  
 ldd  #4
 stb  x
 jmp cc3
 jmp cc3
cc4:  
 jsr ccswitch
 FDB cc5,0
 FDB cc6,1
 FDB cc7,3
 FDB 0
cc3:  
 rts
  END
