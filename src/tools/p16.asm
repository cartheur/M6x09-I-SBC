*  calling monitor c function
*  simple one second wait function

putchar    equ $dfdf 
puts       equ $e041
initacia   equ $df73  
newline    equ $e0eb

wait1s     equ $e750
	
	org $200

main    jsr initacia

loop
        ldd #text3
        pshs d

	jsr puts
	
	leas 2,s

	jsr newline
	jsr wait1s

        bra loop
	
text3   fcc "Hello printing 1s"
        fcb 0

	end

