.filedef temp = R16
.filedef temp1 = R17

	push temp
	push temp1
	lds temp, bt_rc_buf_start
	cpi temp, set_code
	brne elemag_cmd_pop
	lds temp, bt_rc_buf_start + 1
	cpi temp, set_elemag_code
	brne elemag_cmd_pop

	lds temp, bt_rc_buf_start + 2 ; værdien (val), hentes fra inputbufferen.
	cpi temp, 100
	brsh full_speed ; (branch if same or higher)
	mov temp1, temp ; temp1 = temp = val
	add temp, temp1 ; temp = val * 2
	lsr temp1 ;temp1 = Math.floor(val/2)
	add temp, temp1; temp = 2*val + Math.floor(val/2)
	lsr temp1 ;temp = val/4
	lsr temp1 ;temp = val/8
	lsr temp1 ;temp = val/16
	add temp, temp1 ;temp = 2*val + Math.floor(val/2) + Math.floor(val/16)

	setelemag [temp]
	rjmp elemag_cmd_pop

full_elemag:
	setelemag [255]

elemag_cmd_pop:
	pop temp1
	pop temp
