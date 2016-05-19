.include "src/bl/bl.asm"
.filedef temp = R16
.filedef temp1 = R17

.org 0x00
rjmp init

.org 0x2A
rjmp app_command_int_handler

init:
	.include "src/lapt/lapt.asm"
	.include "src/physs/physical_speed.asm"
	.include "src/motor/motor_pwm.asm"

	sbi DDRA, PORTA1
	sbi DDRA, PORTA0
	cbi PORTA, PORTA1
	cbi PORTA, PORTA0

	setspeed [0]

main:
	rjmp main

app_command_int_handler:
	lds temp, bt_rc_buf_start
	cpi temp, set_code
	breq bt_set
	cpi temp, get_code
	breq bt_get
	reti

bt_get:
	lds temp, bt_rc_buf_start + 1
	cpi temp, get_speed_code
	breq bt_get_speed
	reti

bt_set:
	lds temp, bt_rc_buf_start + 1
	cpi temp, set_speed_code
	breq bt_set_speed
	cpi temp, set_stop_code
	breq bt_set_stop
	cpi temp, set_reset_lapt_code
	breq bt_set_reset_lapt
	reti

bt_set_speed: ;val => 2*val + Math.floor(val/2) + Math.floor(val/16)
	lds temp, bt_rc_buf_start + 2
	mov temp1, temp
	subi temp1, 101
	brvs full_speed
	mov temp1, temp
	add temp, temp1
	lsr temp1 ;temp/2
	add temp, temp1
	lsr temp1 ;temp/4
	lsr temp1 ;temp/8
	lsr temp1 ;temp/16
	add temp, temp1
	setspeed [temp]
	reti
full_speed:
	setspeed [255]
	reti

bt_get_speed:
	lds temp, dif_time_h
	send_bt_byte [temp]
	lds temp, dif_time_l
	send_bt_byte [temp]
	reti

bt_set_stop:
	setspeed [0]
	reti

bt_set_reset_lapt:
	rcall reset_lap_timer
	reti
