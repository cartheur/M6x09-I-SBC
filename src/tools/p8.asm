*  simple delay with x register

	org $200

main    lda #1

loop    sta $8000
        rola

        bsr delay

        bra loop

delay   ldx #$3000
delay1  leax -1,x
        bne delay1
        rts


	end

