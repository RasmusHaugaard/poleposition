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
main:
	rjmp main

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"

	jmp_cmd_ne [set_code, 0x20, set_send_on_end]
		push temp1
		lds temp1, bt_rc_buf_start + 2
		sts SEND_ON, temp1
		pop temp1
	set_send_on_end:

	reti

got_i2c_data:
	push temp1
	in temp1, SREG
	push temp1

	lds temp1, SEND_ON
	cpi temp1, 1
	brne got_i2c_data_end
	send_bt_byte [graph_gyrzh_code]
	send_bt_byte [temp2]
	got_i2c_data_end:

	pop temp1
	out SREG, temp1
	pop temp1
	ret

gyr_drdy_isr:
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp2]
	rcall got_i2c_data
	reti
