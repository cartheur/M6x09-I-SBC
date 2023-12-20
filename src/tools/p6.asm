* Indirection

	org $200

main    lda [$c000]   location C000 has 10CE
*                      the byte at 10CE will be sent to gpio1 led
        sta $8000

        swi

	end

