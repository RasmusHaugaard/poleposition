.filedef temp = R16
.filedef valr = R17

.equ track_status_addr = addr
.set addr = addr + 1

.equ last_segment_dis_l_addr = addr
.set addr = addr + 1

.equ last_segment_dis_h_addr = addr
.set addr = addr + 1

.equ in_left_turn_code = 1
.equ in_right_turn_code = 2
.equ on_straight_path_code = 3

.equ turn_in = 30
.equ turn_out = 20

ldi temp, on_straight_path_code
sts track_status_addr, temp

jmp gyr_detect_file_end
gyr_detect_turns:
	push temp
	in temp, SREG
	push temp
	push valr

	lds valr, cur_gyr_val_addr
	lds temp, track_status_addr
	cpi_jmp_eq [temp, on_straight_path_code, on_straight_path]
	cpi temp, in_left_turn_code
	breq in_left_turn
	cpi temp, in_right_turn_code
	breq in_right_turn
	send_bt_byte [108]
gyr_detect_end:
	pop valr
	pop temp
	out SREG, temp
	pop temp
	ret
in_left_turn:
	subi valr, turn_out
	brmi straight_path_detected
	rjmp gyr_detect_end
in_right_turn:
	ldi temp, turn_out
	add valr, temp
	brpl straight_path_detected
	rjmp gyr_detect_end
straight_path_detected:
	ldi temp, on_straight_path_code
	sts track_status_addr, temp

	rjmp gyr_detect_end
on_straight_path:
	subi valr, 0
	brmi negative_val
	;positive val - left
	subi valr, turn_in
	brpl left_turn_detected
	rjmp gyr_detect_end
left_turn_detected:
	ldi temp, in_left_turn_code
	sts track_status_addr, temp
	TODO:
	rjmp gyr_detect_end
negative_val: ;right
	ldi temp, turn_in
	add valr, temp
	brmi right_turn_detected
	rjmp gyr_detect_end
right_turn_detected:
	ldi temp, in_right_turn_code
	sts track_status_addr, temp
	TODO:
	rjmp gyr_detect_end

gyr_detect_file_end:
