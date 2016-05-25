.filedef temp = R16
.filedef L1 = R17
.filedef H1 = R18
.filedef L2 = R19
.filedef H2 = R20
.filedef temp1 = R21
.filedef temp2 = R22

.equ map_data_start_addr = addr
.equ map_data_length = 500
.set addr = addr + map_data_length

.equ map_data_pointer_l_addr = addr
.set addr = addr + 1
.equ map_data_pointer_h_addr = addr
.set addr = addr + 1

.equ map_storer_status = addr
.set addr = addr + 1

.equ map_segment_count = addr
.set addr = addr + 1

.equ first_map_segment_count = addr
.set addr = addr + 1

.equ mstore_stat_not_started = 0
.equ mstore_stat_started = 1

.equ last_dis_h_addr = addr
.set addr = addr + 1
.equ last_dis_l_addr = addr
.set addr = addr + 1

.equ straight_segment = 255
.equ left_segment = 251
.equ right_segment = 253

jmp map_storer_file_end

reset_map_data_pointer:
	push temp
	ldi temp, low(map_data_start_addr)
	sts map_data_pointer_l_addr, temp
	ldi temp, high(map_data_start_addr)
	sts map_data_pointer_h_addr, temp
	pop temp
	ret

map_storer_init:
	push XH
	push XL
	push temp

	rcall reset_map_data_pointer
	lds XH, map_data_pointer_h_addr
	lds XL, map_data_pointer_l_addr
	ldi temp, straight_segment
	st X+, temp
	sts map_data_pointer_h_addr, XH
	sts map_data_pointer_l_addr, XL

	ldi temp, 0
	sts last_segment_dis_h_addr, temp
	sts last_segment_dis_l_addr, temp
	sts map_segment_count, temp

	pop temp
	pop XL
	pop XH
	ret

.macro push_store_detect
	push temp
	push XH
	push XL
	push H1
	push L1
	push H2
	push L2
.endm

right_turn_det_store:
	push_store_detect

	get_dis [h1, l1]
	send_bt_bytes [graph_detected_right_turn_code, h1, l1]

	rcall det_store
	ldi temp, right_segment
	st X+, temp
	rjmp store_end

left_turn_det_store:
	push_store_detect

	get_dis [h1, l1]
	send_bt_bytes [graph_detected_left_turn_code, h1, l1]

	rcall det_store
	ldi temp, left_segment
	st X+, temp
	rjmp store_end

straight_path_det_store:
	push_store_detect

	get_dis [h1, l1]
	send_bt_bytes [graph_detected_straight_path_code, h1, l1]

	rcall det_store
	ldi temp, straight_segment
	st X+, temp
	rjmp store_end

det_store:
	get_dis [H1, L1]
	push H1
	push L1
	lds H2, last_segment_dis_h_addr
	lds L2, last_segment_dis_l_addr
	sub L1, L2
	sbc H1, H2
	pop L2
	pop H2
	sts last_segment_dis_l_addr, L2
	sts last_segment_dis_h_addr, H2
	lds XH, map_data_pointer_h_addr
	lds XL, map_data_pointer_l_addr
	push temp
	lds temp, track_status_addr
	cpi temp, on_straight_path_code
	brne was_a_turn
	ldi temp, straight_segment
	st X+, temp
	rjmp det_store_end
was_a_turn:
	rcall gyr_integrate_store
det_store_end:
	pop temp
	ld H2, X+
	ld L2, X
	add L1, L2
	adc H1, H2
	dec XL
	sbci XH, 0
	st X+, H1
	st X+, L1
	ret

store_end:
	sts map_data_pointer_h_addr, XH
	sts map_data_pointer_l_addr, XL
	lds temp, map_segment_count
	inc temp
	sts map_segment_count, temp

	pop L2
	pop H2
	pop L1
	pop H1
	pop XL
	pop XH
	pop temp
	ret

map_store_done:
	push temp
	in temp, SREG
	push temp
	push temp1

	rcall straight_path_det_store

	lds temp, map_round_addr
	cpi temp, 0
	lds temp, map_segment_count
	breq first_mapping
	lds temp1, first_map_segment_count
	cp temp1, temp
	brne segment_length_error
	rjmp map_store_done_end
first_mapping:
	sts first_map_segment_count, temp
map_store_done_end:
	pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret

segment_length_error:
	setspeed [0]
	delays [2]
	force_send_bt_byte [segment_count_error]
	lds temp, map_segment_count
	force_send_bt_byte [temp]
	lds temp, first_map_segment_count
	force_send_bt_byte [temp]
	sei
	rjmp segment_length_error

map_storer_file_end:
