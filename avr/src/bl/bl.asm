.set addr = 0x60  ; her starter sram, hvor der kan gemmes data under kørslen

.include "src/def/m32def.inc"
.include "src/protocol/tr.inc"
.include "src/protocol/rc.inc"

.equ bootload_start = LARGEBOOTSTART
.org bootload_start
	rjmp boot_init

.org bootload_start + 0x2A
boot_init:
	.include "src/util/setup/stack_pointer.asm"
	.include "src/util/macros/delay.asm"
	.include "src/util/macros/soft_reset.asm"
	.include "src/bt/macros/tr_force.asm"
	.include "src/bt/bt.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/bl/flasher/flasher.asm"
	force_send_bt_byte [avr_was_reset]
	delays [2] ; delay application to make sure, capacitor is not draining i2c circuits.
	jmp 0x00
