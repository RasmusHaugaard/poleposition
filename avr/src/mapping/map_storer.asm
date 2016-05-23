.filedef temp = R16
.filedef L1 = R17
.filedef H1 = R18
.filedef L2 = R19
.filedef H2 = R20
.filedef temp1 = R21
.filedef temp2 = R22

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

jmp map_storer_file_end

map_clear_sram:
	push temp
	in temp, SREG
	push temp
	push temp1
	push temp2
	push XL
	push XH

	ldi temp2, 0
	ldi XL, low(map_data_pointer_l)
	ldi XH, high(map_data_pointer_h)
	ldi temp, low(map_data_length)
	ldi temp1, high(map_data_length)
map_clear_loop:
	st X+, temp2
	dec temp
	brne map_clear_loop
	cpi temp1, 0
	breq map_clear_end
	dec temp1
	brne map_clear_loop
map_clear_end:

	pop XH
	pop XL
	pop temp2
	pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret

map_storer_init:
	push XH
	push XL
	push temp

	rcall reset_physs_dis
	rcall reset_map_data_pointer
	lds XH, map_data_pointer_h
	lds XL, map_data_pointer_l
	ldi temp, straight_segment
	st X+, temp
	sts map_data_pointer_h, XH
	sts map_data_pointer_l, XL

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
	rcall det_store
	ldi temp, right_segment
	st X+, temp
	rjmp store_end

left_turn_det_store:
	push_store_detect
	rcall det_store
	ldi temp, left_segment
	st X+, temp
	rjmp store_end

straight_path_det_store:
	push_store_detect
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

	lds XH, map_data_pointer_h
	lds XL, map_data_pointer_l
	rcall gyr_integrate_store
	ld X+, H2
	ld X, L2
	add L1, L2
	adc H1, H2
	dec XL
	ldi temp, 0
	sbc XH, temp
	st X+, H1
	st X+, L1
	ret

store_end:
	sts map_data_pointer_h, XH
	sts map_data_pointer_l, XL
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

	lds temp, map_round_addr
	cpi temp, 1
	lds temp, map_segment_count
	breq first_mapping

	lds temp1, first_map_segment_count
	cpi temp1, temp
	brne segment_length_error

	rjmp after_map_segment_count
first_mapping:
	sts first_map_segment_count, temp
after_map_segment_count:
	rcall straight_path_det_store

	pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret

segment_length_error:
	setspeed [0]
	delays [2]
	force_send_bt_byte [segment_count_error]
	rjmp segment_length_error

map_storer_file_end:
