	org $200

loop	ldd #$1234
        ldx #$5678
	addd ,x
	swi

	end

