; Shared M6x09-I hardware and serial routines.
;
; The 2020 kit monitor listing uses $A000/$A001 for the 6850 ACIA.
; The routines below are intentionally self-contained so applications do
; not depend on a particular monitor ROM entry-point layout.

GPIO1        = $8000
ACIA_CONTROL = $A000
ACIA_DATA    = $A001

; Configure the 6850 for the verified 19,200-bit/s link.
InitAcia
        LDA   #$03
        STA   ACIA_CONTROL
        LDA   #$16
        STA   ACIA_CONTROL
        LDA   ACIA_DATA
        RTS

; Send the character in A after the transmit-data-register-empty bit is set.
PutChar
        PSHS  A
PutCharWait
        LDA   #$02
        BITA  ACIA_CONTROL
        BEQ   PutCharWait
        PULS  A
        STA   ACIA_DATA
        RTS

; Send a zero-terminated string addressed by X.
PutString
        LDA   ,X+
        BEQ   PutStringDone
        JSR   PutChar
        BRA   PutString
PutStringDone
        RTS

Newline
        LDA   #$0D
        JSR   PutChar
        LDA   #$0A
        JMP   PutChar

; Print the low nibble of A as one upper-case hexadecimal digit.
PutHexDigit
        ANDA  #$0F
        ADDA  #'0'
        CMPA  #'9'
        BLS   PutHexDigitSend
        ADDA  #7
PutHexDigitSend
        JMP   PutChar
