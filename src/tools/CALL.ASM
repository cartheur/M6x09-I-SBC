; small-c V2.3
; char a;

 .globl a
a: 
 .ds 1
; delay(n)

 .module delay

 .globl delay
delay: 
; char n;
; {
;   a=n;
 leay 3,s
 tfr  y,d
 pshs d
 ldb  [,s++]
 sex
 stb  a
; }
 rts
; main()

 .globl main
main: 
; {
;   delay(1);
 ldd  #1
 pshs d
 jsr delay
 leas 2,s
; }
 rts
;    .end
