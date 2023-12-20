* Indirection

	org $200

main    lda [$c000]
        sta $8000

        swi

	end

