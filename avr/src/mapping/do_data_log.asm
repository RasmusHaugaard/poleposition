.filedef temp = R16
.filedef dh = R17
.filedef dl = R18

rjmp do_data_log_file_end

do_data_log:
	push dh
	push dl
	push temp
	in temp, SREG
	push temp

	get_dis [dh, dl]
	lds temp, cur_gyr_val_addr
	send_bt_bytes [graph_gyrzhDis_code, dh, dl, temp]

	pop temp
	out SREG, temp
	pop temp
	pop dl
	pop dh
	ret

do_data_log_file_end:
