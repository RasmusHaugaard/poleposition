.include "src/bl/bl.asm"
.filedef temp1 = R16
.filedef temp2 = R17

.equ SEND_ON = addr
.set addr = addr + 1

.org 0x00
rjmp init

.org 0x2A
rjmp cmd_handler

init:
	.include "src/motor/setup.asm"
	.include "src/elemag/setup.asm"
	.include "src/i2c/setup.asm"
	.include "src/i2c/gyr/setup.asm"
	.include "src/i2c/gyr/setup_drdy_int.asm"

	ldi temp1, 0
	sts SEND_ON, temp1

	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
	;send_bt_byte [graph_gyrzh_code]
	;send_bt_byte [temp1]
main:
	rjmp main

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"

	jmp_cmd_ne [set_code, 0x20, set_send_on_end]
		lds temp1, bt_rc_buf_start + 2
		sts SEND_ON, temp1
	set_send_on_end:


	reti

gyr_drdy_isr:
	push temp1
	push temp2
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
	lds temp2, SEND_ON
	cpi temp2, 1
	brne gyr_drdy_isr_end
	send_bt_byte [graph_gyrzh_code]
	send_bt_byte [temp1]
gyr_drdy_isr_end:
	pop temp2
	pop temp1
	reti
