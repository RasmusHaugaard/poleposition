.filedef temp = R16
.filedef temp1 = R17
.filedef temp2 = R18
.filedef temp3 = R19

rjmp linedetector_handler_file_end

linedetector_handler:
	push temp
	in temp, SREG
	push temp

	lds temp, race_status_addr
	cpi temp, race_status_warm_up
	brne was_not_warm_up
	rcall start_create_map
	rjmp linedetector_end
was_not_warm_up:
	cpi temp, race_status_mapping
	brne was_not_mapping
	rcall finished_map_round
	set_control_speed [255]
	rjmp linedetector_end
was_not_mapping:
	cpi temp, race_status_racing
	brne was_not_racing
	rcall finished_race_lap
	rjmp linedetector_end
was_not_racing:
race_status_error:
	delays [2]
	send_bt_byte [race_status_error_code]
	sei
	rjmp race_status_error

linedetector_end:
	rcall reset_lap_timer
	rcall reset_physs_dis

	pop temp
	out SREG, temp
	pop temp
	reti

send_lap_stats:
	push temp3
	push temp2
	push temp1
	push temp
	in temp, SREG
	push temp

	get_time_full [temp3, temp2, temp1]
	get_dis [temp1, temp]
	send_bt_bytes [graph_next_lap_code, temp3, temp2, temp1, temp]

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop temp2
	pop temp3
	ret


linedetector_handler_file_end:
