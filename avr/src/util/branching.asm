.macro cpi_rjmp_eq
.endm
.macro cpi_rjmp_eq_8_i_i
	cpi @0, @1
	brne PC + 2
	rjmp @2
.endm

.macro cpi_rjmp_ne
.endm
.macro cpi_rjmp_ne_8_i_i
	cpi @0, @1
	breq PC + 2
	rjmp @2
.endm

.macro cpi_jmp_eq
.endm
.macro cpi_jmp_eq_8_i_i
	cpi @0, @1
	brne PC + 3
	jmp @2
.endm

.macro cpi_jmp_ne
.endm
.macro cpi_jmp_ne_8_i_i
	cpi @0, @1
	breq PC + 3
	jmp @2
.endm
