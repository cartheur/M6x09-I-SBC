*  calling monitor c function
*  display text on lcd 

	org $200

init_lcd  equ $c228
pstring   equ $c26b

main    jsr init_lcd

        ldd #text1
        pshs d

	jsr pstring
	
	leas 2,s
	swi

text1   fcc "Hello from 6809"
        fcb 0 

	end

