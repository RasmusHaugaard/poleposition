.include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2a
init:
	.include "src/lapt/lapt.asm"
	.include "src/physs/physical_speed.asm"

main:
	rjmp main
