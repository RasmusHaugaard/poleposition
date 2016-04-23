.include "src/bl/bl.asm"

.filedef temp = R16
.equ ON_ADDR = addr
.set addr = addr + 1

.org 0x00
	rjmp init
.org 0x26
	rjmp twint_handler
.org 0x2a
	rjmp command_handler

init:
	.include "src/util/branching.asm"
	.include "src/bt/bt_rc_force.asm"
	.include "src/i2c/i2c.asm"
	.include "src/motor/motor_pwm.asm"
	sei
	ldi temp, 0
	sts ON_ADDR, temp
	rjmp main

main:
	delayms [3]
	lds temp, ON_ADDR
	cpi temp, 1
	brne main
	;send_bt_byte [90]
	rcall I2C_next
	rjmp main

command_handler:
	lds temp, ON_ADDR
	cpi temp, 1
	breq TURN_OFF
	rjmp TURN_ON

TURN_OFF:
	ldi temp, 0
	sts ON_ADDR, temp
	setspeed [0]
	ret

TURN_ON:
	ldi temp, 1
	sts ON_ADDR, temp
	setspeed [110]
	ret

gotAccX_R16:
	;send_bt_byte [30]
	;send_bt_byte [R16]
	ret

gotAccY_R16:
	send_bt_byte [31]
	send_bt_byte [R16]
	ret

gotAccZ_R16:
	;send_bt_byte [32]
	;send_bt_byte [R16]
	ret

gotGyrX_R16:
	;send_bt_byte [40]
	;send_bt_byte [R16]
	ret

gotGyrY_R16:
	;send_bt_byte [41]
	;send_bt_byte [R16]
	ret

gotGyrZ_R16:
	;send_bt_byte [42]
	;send_bt_byte [R16]
	ret
