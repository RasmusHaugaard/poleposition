.filedef temp = R16
.filedef temp1 = R17

	jmp_cmd_ne [set_code, set_elemag_code, elemag_cmd_end]
		I2C_IE_MAK
	mak_end:
	push temp
	in temp, SREG
	push temp
	push temp1

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
	out SREG, temp
	pop temp
elemag_cmd_end:
