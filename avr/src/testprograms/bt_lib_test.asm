.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	ldi ZH, 0
	ldi ZL, 0x1a * 2
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	jmp init

.org 0x1a
  ;jmp bl_rxcie_handler; USART RX Complete Handler
.org 0x1c
  ;jmp bl_udrei_handler ; UDR Empty handler
.org 0x2a
init:
	force_send_bt_byte [255]
	send_bt_byte [0]
	jmp main
.org 500
main:
	rjmp main
