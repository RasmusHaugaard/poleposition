.include "src/bl/bl.asm"

.org 0x00
	rjmp init
.org 0x2A

init:
.include "src/lapt/lapt.asm"

main:
	jmp main
