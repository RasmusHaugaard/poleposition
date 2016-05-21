.macro cpi_jmp_eq
	.error "Skal kaldes med argumenter"
.endm
.macro cpi_jmp_eq_8_i_i
	cpi @0, @1
	brne PC + 3
	jmp @2
.endm

.macro cpi_jmp_ne
	.error "Skal kaldes med argumenter"
.endm
.macro cpi_jmp_ne_8_i_i
	cpi @0, @1
	breq PC + 3
	jmp @2
.endm
