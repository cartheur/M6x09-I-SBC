*  calling monitor c function
*  display ascii letter on lcd 

init_lcd equ $c228
putch_lcd equ $c2f5
	
	org $200

main    jsr init_lcd

        ldb #$36
        pshs d
	jsr putch_lcd
	leas 2,s
	swi

	end

