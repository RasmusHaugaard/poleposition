.include "src/bl/bl.asm"

.org 0x00
	rjmp init
.org 0x26
	rjmp twint_handler
.org 0x2a
init:
	.include "src/util/branching.asm"
	.include "src/bt/bt_rc_force.asm"
	.include "src/i2c/i2c.asm"
	sei
	send_bt_byte [201]
	force_receive_bt_byte
	delays [5]
	rjmp main

main:
	delayms [200]
	rcall I2C_next
	rjmp main

gotAccX_R16:
	send_bt_byte [30]
	send_bt_byte [R16]
	ret

gotAccY_R16:
	send_bt_byte [31]
	send_bt_byte [R16]
	ret

gotAccZ_R16:
	send_bt_byte [32]
	send_bt_byte [R16]
	ret
