.include "src/def/m32def.inc"
.include "src/def/data.inc"
.include "src/def/protocol.inc"

.equ bootload_start = LARGEBOOTSTART

.org bootload_start
	rjmp boot_init
.org bootload_start + 0x1A
	rjmp pf_bl_rxcie_handler
.org bootload_start + 0x2A
boot_init:
	.include "src/setup/stack_pointer.asm"
	.include "src/util/delay.asm"
	.include "src/util/soft_reset.asm"
	.include "src/bt/bt_tr_force.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/bl/program_flash.asm"
	force_send_bt_byte [avr_was_reset]
	jmp 0x00
