.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org 0x00
  rjmp init
.org 0x1a
  jmp bl_rxcie_handler; USART RX Complete Handler
.org 0x1c
  jmp bl_udrei_handler ; UDR Empty handler
.org 0x2a
init:
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_bl.asm"
main:
	rjmp main
