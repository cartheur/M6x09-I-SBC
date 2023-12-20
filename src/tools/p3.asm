	org $200

main    lda #$aa

        ldx #$1000  base address

        sta ,x

        sta 1,x

        sta 2,x

        sta 3,x 

        sta -1,x

        sta $7f,x

        sta $1000,x

        swi

	end

