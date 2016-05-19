.filedef temp = R16
.filedef temp1 = R17

	push temp
	push temp1
	lds temp, bt_rc_buf_start
	cpi temp, set_code
	brne elemag_bt_app_command_pop
	lds temp, bt_rc_buf_start + 1
	cpi temp, set_elemag_code
	brne elemag_bt_app_command_pop
;val => 2*val + Math.floor(val/2) + Math.floor(val/16)
	lds temp, bt_rc_buf_start + 2
	cpi temp1, 100
	brsh full_elemag
	mov temp1, temp
	add temp, temp1
	lsr temp1 ;temp/2
	add temp, temp1
	lsr temp1 ;temp/4
	lsr temp1 ;temp/8
	lsr temp1 ;temp/16
	add temp, temp1
	setelemag [temp]
	rjmp elemag_bt_app_command_pop

full_elemag:
	setelemag [255]

elemag_bt_app_command_pop:
	pop temp1
	pop temp
