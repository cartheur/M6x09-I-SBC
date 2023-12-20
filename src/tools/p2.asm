	org $200

main    lda #0
        tfr a,dp
        lda #$aa 

        sta $8000
        sta $40
        sta $6000

        swi

	end

