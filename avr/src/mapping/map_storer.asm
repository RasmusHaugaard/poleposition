.filedef temp = R16
.filedef D1L = R17
.filedef D1H = R18
.filedef D2L = R19
.filedef D2H = R20

.equ map_storer_status = addr
.set addr = addr + 1

.equ map_segment_count = addr
.set addr = addr + 1

.equ mstore_stat_not_started = 0
.equ mstore_stat_started = 1

.equ last_dis_h_addr = addr
.set addr = addr + 1
.equ last_dis_l_addr = addr
.set addr = addr + 1

jmp map_storer_file_end

map_storer_init:
	push XH
	push XL
	push temp

	rcall reset_map_data_pointer
	lds XH, map_data_pointer_h
	lds XL, map_data_pointer_l
	ldi temp, straight_segment
	st X+, temp
	sts map_data_pointer_h, XH
	sts map_data_pointer_l, XL

	ldi temp, 0
	sts last_dis_h_addr, temp
	sts last_dis_l_addr, temp
	sts map_segment_count, temp

	pop temp
	pop XL
	pop XH
	ret

.macro push_store_detect
	push temp
	push XH
	push XL
	push D1H
	push D1L
	push D2H
	push D2L
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
	get_dis [D1H, D1L]
	push D1H
	push D1L
	lds D2H, last_segment_dis_h_addr
	lds D2L, last_segment_dis_l_addr
	sub D1L, D2L
	sbc D1H, D2H
	pop D2L
	pop D2H
	sts last_segment_dis_l_addr, D2L
	sts last_segment_dis_h_addr, D2H

	lds XL, map_data_pointer_l
	lds XH, map_data_pointer_h
	st X+, D1L
	st X+, D1H
	ret

store_end:
	sts map_data_pointer_l, XL
	sts map_data_pointer_h, XH

	lds temp, map_segment_count
	inc temp
	sts map_segment_count, temp

	pop D2L
	pop D2H
	pop D1L
	pop D1H
	pop XL
	pop XH
	pop temp
	ret

map_store_done:
	rcall straight_path_det_store
	lds temp, map_segment_count
	send_bt_byte [temp]
	ret

map_storer_file_end:
