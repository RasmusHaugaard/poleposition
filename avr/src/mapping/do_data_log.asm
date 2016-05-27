.filedef temp = R16
.filedef temp1 = R17
.filedef dh = R18
.filedef dl = R19

rjmp do_data_log_file_end

do_data_log:
	push dh
	push dl
	push temp1
	push temp
	in temp, SREG
	push temp

	get_dis [dh, dl]

	lds temp, race_status_addr
	cpi temp, race_status_mapping
	brne log_not_mapping
log_mapping:
	rcall send_bt_gyr_int
	rcall send_bt_gyr
log_not_mapping:
	lds temp, race_status_addr
	cpi temp, race_status_racing
	brne log_not_racing
log_racing:
	;rcall send_bt_gyr
	;rcall send_bt_speed
	;rcall send_bt_braking_distance
log_not_racing:

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop dl
	pop dh
	ret

send_bt_gyr_int:
	lds temp1, gyr_integration_h_addr
	lds temp, gyr_integration_l_addr
	lsl temp
	rol temp1
	send_bt_bytes [graph_gyr_int_code, dh, dl, temp1]
	ret

send_bt_gyr:
	lds temp, cur_gyr_val_addr
	send_bt_bytes [graph_gyrzhDis_code, dh, dl, temp]
	ret

send_bt_speed:
	phys_speed [temp]
	get_kin_energy [temp]
	send_bt_bytes [graph_speedDis_code, dh, dl, temp]
	ret

send_bt_braking_distance:
	lds temp, breaking_distance_l_addr
	lds temp1, breaking_distance_h_addr
	send_bt_bytes [graph_breakingDis_code, dh, dl, temp1, temp]
	ret

do_data_log_file_end:
