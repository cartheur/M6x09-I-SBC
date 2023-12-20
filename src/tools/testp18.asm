*  calling monitor c function
*  display text on 7-segment display

buffer     equ $7035
scan       equ $c896
scan1      equ $df09 
	
	org $270

main    lda #0
        sta buffer
	lda #$a3
	sta buffer+1
	lda #$85
	sta buffer+2
	lda #$85
	sta buffer+3
	lda #$8f
	sta buffer+4
	lda #$37
	sta buffer+5

loop	jsr scan
	bra loop

	end

