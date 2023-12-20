* using A+X form effective address

	org $200

main    lda #5
        ldb #$55 

        ldx #$1000  base address

        sta b,x

        swi

	end

