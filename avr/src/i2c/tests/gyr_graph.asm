.include "src/bl/bl.asm"
.filedef temp1 = R16
.filedef temp2 = R17


.equ SEND_ON = addr
.set addr = addr + 1

.org 0x00
rjmp init
.org 0x02
rjmp EXT_INT0
.org 0x04
rjmp EXT_INT1
.org 0x2A
rjmp app_command_int_handler

init:
	.include "src/lapt/lapt.asm"
	.include "src/physs/physical_speed.asm"
	.include "src/motor/motor_pwm.asm"
	.include "src/elemag/elemag_pwm.asm"
	.include "src/i2c/i2c_setup.asm"
	.include "src/i2c/i2c_setup_gyr.asm"

	in temp1, GICR
	andi temp1, 1<<INT0
	out GICR, temp1

	ldi temp1, 0
	sts SEND_ON, temp1

	;I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
main:
	rjmp main

app_command_int_handler:
	.include "src/motor/motor_bt_app_command.asm"
	.include "src/elemag/elemag_bt_app_command.asm"

	jmpne_app_cmd [set_code, 0x20, set_send_on_end]
	push temp1
	lds temp1, bt_rc_buf_start + 2
	sts SEND_ON, temp1
	send_bt_byte [temp1]
	pop temp1
	set_send_on_end:
	send_bt_byte [210]
	reti

EXT_INT0:
	send_bt_byte [199]
	reti
	push temp1
	push temp2
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
	lds temp2, SEND_ON
	cpi temp2, 1
	brne ext_int0_end
	send_bt_byte [graph_gyrzh_code]
	send_bt_byte [temp1]
ext_int0_end:
	pop temp2
	pop temp1
	reti
