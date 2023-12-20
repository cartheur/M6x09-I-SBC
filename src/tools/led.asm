	org $200

main	lda #1

loop	sta $8000
        bsr delay1
	inca
	bra loop
	

delay1	ldb #$00
delay	decb
	bne delay
        rts

	end

