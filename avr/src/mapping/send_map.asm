rjmp send_map_file_end
.filedef temp = R16
.filedef val = R17
.filedef cnt = R18

send_map:
	ldi XH, high(map_data_start_addr)
	ldi XL, low(map_data_start_addr)
	lds cnt, map_segment_count
	lsl cnt
	lsl cnt
send_map_loop:
	ld val, X+
	send_bt_byte [val]
	dec cnt
	brne send_map_loop
ret

send_map_file_end:
