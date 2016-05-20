.include "src/bl/bl.asm"
.filedef temp = R16
.filedef temp1 = R17

.org 0x00
rjmp init

.org 0x2A
rjmp app_command_int_handler

init:
	.include "src/ex1/ex1.asm"
	.include "src/lapt/fixed/lapt_fixed.asm"
	.include "src/physs/fixed/physical_speed_fixed.asm"
	.include "src/motor/motor_pwm.asm"

	sbi DDRA, PORTA1
	nop
	sbi DDRA, PORTA0
	nop
	cbi PORTA, PORTA1
	nop
	cbi PORTA, PORTA0
	nop
	sbi DDRB, PORTB3
	nop
	cbi DDRB, PORTB3


	setspeed [0]

main:
	ldi R20, 000
	send_bt_byte [R20]
	lds R20, dif_time_h
	send_bt_byte [R20]
	lds R20, dif_time_l
	send_bt_byte [R20]

	delays [1]
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

bt_set_speed:
	lds temp, bt_rc_buf_start + 2
	mov temp1, temp
	subi temp1, 100
	brvs full_speed
	lsl temp
	setspeed [temp]
	reti
full_speed:
	setspeed [200]
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
