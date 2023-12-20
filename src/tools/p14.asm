*  calling monitor c function
*  display text on terminal using UART

putchar    equ $dfdf 
puts       equ $e041
initacia   equ $df73  

	org $200

main    jsr initacia

loop
        ldb #'A'
        pshs d

	jsr putchar
	
	leas 2,s
        bra loop
	

	end

