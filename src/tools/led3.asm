	org $200

	lbra $280

	org $280

loop	inca
	sta $8000
        bsr delay1
	bra loop
	
        
delay1	ldx #$3000
delay	leax -1,x
	bne delay
	nop
	nop
        rts

	end

