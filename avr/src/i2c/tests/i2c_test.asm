.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_setup.asm"
	jmp 0x00

.org 0x00
	rjmp init
.org 0x26
	rjmp twint_handler
.org 0x2a
init:
	.include "src/bt/bt_tr_force.asm"
	.include "src/bt/bt_rc_force.asm"
	.include "src/macros/delay.asm"
	.include "src/util/branching.asm"

	.include "src/i2c/i2c.asm"
	force_send_bt_byte [255]
	sei
	rjmp main

main:
	force_receive_bt_byte
	rcall I2C_next
	rjmp main
