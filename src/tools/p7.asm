*  branch an long branch

	org $200

main    lda $c000   location C000 has 10CE
*                      the byte at 10CE will be sent to gpio1 led
        sta $8000

        bra  load_b

        nop
        nop

        lbra load_b

        nop
        nop

load_b  ldb $c001

        exg a,b



        swi

	end

