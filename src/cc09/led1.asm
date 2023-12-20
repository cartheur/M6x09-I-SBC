	org $200

loop	inca
	sta $8000
        bsr delay1
	bra loop
	

delay1	ldx #$3000
delay	leax -1,x
	bne delay
        rts

	end

