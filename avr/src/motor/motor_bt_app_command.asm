.filedef temp = R16
.filedef temp1 = R17

	push temp
	push temp1
	lds temp, bt_rc_buf_start
	cpi temp, set_code
	brne motor_bt_app_command_pop
	lds temp, bt_rc_buf_start + 1
	cpi temp, set_speed_code
	breq bt_set_speed
	cpi temp, set_stop_code
	breq bt_set_stop
	rjmp motor_bt_app_command_pop

bt_set_speed: ;val => 2*val + Math.floor(val/2) + Math.floor(val/16)
	lds temp, bt_rc_buf_start + 2
	cpi temp, 100
	brsh full_speed
	mov temp1, temp
	add temp, temp1
	lsr temp1 ;temp/2
	add temp, temp1
	lsr temp1 ;temp/4
	lsr temp1 ;temp/8
	lsr temp1 ;temp/16
	add temp, temp1
	setspeed [temp]
	rjmp motor_bt_app_command_pop
full_speed:
	setspeed [255]
	rjmp motor_bt_app_command_pop

bt_set_stop:
	setspeed [0]
	rjmp motor_bt_app_command_pop

motor_bt_app_command_pop:
	pop temp1
	pop temp
