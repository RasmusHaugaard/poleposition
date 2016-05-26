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

.equ turn_in = 20
.equ turn_out = 5

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
	send_bt_byte [temp]
gyr_detect_end:
	pop valr
	pop temp
	out SREG, temp
	pop temp
	ret

on_straight_path:
	subi valr, 0
	brmi on_straight_path_check_right
	;positive val - left
	subi valr, turn_in
	brpl left_turn_detected
	rjmp gyr_detect_end
on_straight_path_check_right: ;negative val - right
	ldi temp, turn_in
	add valr, temp
	brmi right_turn_detected
	rjmp gyr_detect_end
in_left_turn:
	rcall gyr_integrate
	subi valr, turn_out
	brmi straight_path_detected
	rjmp gyr_detect_end
in_right_turn:
	rcall gyr_integrate
	ldi temp, turn_out
	add valr, temp
	brpl straight_path_detected
	rjmp gyr_detect_end

straight_path_detected:
	lds temp, race_status_addr
	cpi temp, race_status_mapping
	brne straight_path_det_not_mapping
	rcall straight_path_det_store
straight_path_det_not_mapping:
	ldi temp, on_straight_path_code
	sts track_status_addr, temp
	rjmp gyr_detect_end

left_turn_detected:
	lds temp, race_status_addr
	cpi temp, race_status_mapping
	brne left_turn_det_not_mapping
	rcall left_turn_det_store
	rcall start_gyr_integration
left_turn_det_not_mapping:
	ldi temp, in_left_turn_code
	sts track_status_addr, temp
	rjmp gyr_detect_end

right_turn_detected:
	lds temp, race_status_addr
	cpi temp, race_status_mapping
	brne right_turn_det_not_mapping
	rcall right_turn_det_store
	rcall start_gyr_integration
right_turn_det_not_mapping:
	ldi temp, in_right_turn_code
	sts track_status_addr, temp
	rjmp gyr_detect_end

gyr_detect_file_end:
