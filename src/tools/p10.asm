*  calling monitor c function
*  display text "Hi      "

	org $200

scan    equ $c896
gpio1   equ $8000
buffer  equ $7035

main    ldx #buffer
        lda #$37
	sta 5,x

        lda #$89
        sta 4,x

        clr 3,x
        clr 2,x
        clr 1,x
	clr 0,x

loop    jsr scan
        stb gpio1 
        bra loop

	end

