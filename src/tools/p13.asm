*  calling monitor c function
*  display text on lcd 

init_lcd  equ $c228
pstring   equ $c26b
goto_xy   equ $c197

	org $200
main    jsr init_lcd

        ldd #text1
        pshs d

	jsr pstring
	
	leas 2,s
        
	ldb #$00
	pshs d
	ldb #$01
	pshs d

	jsr goto_xy

	leas 4,s

	ldd #text2
        pshs d

	jsr pstring
	
	leas 2,s
	
	swi

text1   fcc "Hello from 6809"
        fcb 0 
text2   fcc "Enter code in HEX"
        fcb 0 

	end

