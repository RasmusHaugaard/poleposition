rjmp send_map_file_end
.filedef temp = R16
.filedef val = R17
.filedef cnt = R18

send_map:
	push cnt
	push val
	push temp
	in temp, SREG
	push temp

	delayms [100]

	ldi XH, high(map_data_start_addr)
	ldi XL, low(map_data_start_addr)
	lds cnt, first_map_segment_count
	force_send_bt_byte [0]
	force_send_bt_byte [cnt]
	force_send_bt_byte [0]
send_map_loop:
	ld val, X+
	force_send_bt_byte [val]
	ld val, X+
	force_send_bt_byte [val]
	ld val, X+
	force_send_bt_byte [val]
	ld val, X+
	force_send_bt_byte [val]
	dec cnt
	brne send_map_loop

	pop temp
	out SREG, temp
	pop temp
	pop val
	pop cnt
ret

send_map_file_end:
