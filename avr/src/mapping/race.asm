.filedef temp = R16
.filedef temp1 = R17
.filedef offset = R18
.filedef dh = R19
.filedef dl = R20

.equ straight_control_speed = 0
.equ elemag_power = 70
.equ start_brake_length_constant = 30

rjmp race_file_end

turn_speed_table:
	;inner - outer
	.db 70, 73 ; 1 segment
	.db 80, 78 ; 2 segmenter
	.db 85, 85 ; 3 segmenter
	.db 85, 85 ; 4 segmenter
	.db 85, 85 ; 5 segmenter

.equ race_cur_segment_type_addr = addr
.set addr = addr + 1

.equ race_segment_straight = 255
.equ race_segment_turn = 254

.equ race_map_data_pointer_l_addr = addr
.set addr = addr + 1
.equ race_map_data_pointer_h_addr = addr
.set addr = addr + 1

.equ race_map_segment_index_addr = addr
.set addr = addr + 1

.equ cur_segment_length_l_addr = addr
.set addr = addr + 1
.equ cur_segment_length_h_addr = addr
.set addr = addr + 1

.equ accept_turn_distance_l_addr = addr
.set addr = addr + 1
.equ accept_turn_distance_h_addr = addr
.set addr = addr + 1

.equ next_turn_speed_addr = addr
.set addr = addr + 1

.equ next_turn_kin_energy_addr = addr
.set addr = addr + 1

.equ has_started_braking_addr = addr
.set addr = addr + 1

.equ breaking_distance_h_addr = addr
.set addr = addr + 1
.equ breaking_distance_l_addr = addr
.set addr = addr + 1

finished_race_lap:
	rcall start_race_lap
	ret

start_race_lap:
	push temp

	ldi temp, low(map_data_start_addr - 4)
	sts race_map_data_pointer_l_addr, temp
	ldi temp, high(map_data_start_addr - 4)
	sts race_map_data_pointer_h_addr, temp

	ldi temp, 0
	sts race_map_segment_index_addr, temp

	rcall race_next_segment
	set_control_speed [straight_control_speed]

	pop temp
	ret

race_next_segment:
	rcall reset_physs_dis

	lds temp, 0
	sts has_started_braking_addr, temp
	lds temp, race_map_segment_index_addr
	inc temp
	sts race_map_segment_index_addr, temp
	lds YH, race_map_data_pointer_h_addr
	lds YL, race_map_data_pointer_l_addr
	adiw YH:YL, 4
	sts race_map_data_pointer_h_addr, YH
	sts race_map_data_pointer_l_addr, YL
	rcall race_cache_segment_data
	ret

race_cache_segment_data:
	push YH
	push YL
	push ZH
	push ZL
	push temp1
	push temp
	in temp, SREG
	push temp

	lds YH, race_map_data_pointer_h_addr
	lds YL, race_map_data_pointer_l_addr
	ld temp, Y
	cpi temp, straight_segment
	brne race_cache_turn
race_cache_straight:
	ldi temp, race_segment_straight
	sts race_cur_segment_type_addr, temp

	lds temp, race_map_segment_index_addr
	lds temp1, first_map_segment_count
	cp temp, temp1
	brne not_last_segment
last_segment:
	ldi temp, 0x88
	sts cur_segment_length_h_addr, temp
	sts cur_segment_length_h_addr, temp
	sts accept_turn_distance_h_addr, temp
	sts accept_turn_distance_l_addr, temp
	sts next_turn_kin_energy_addr, temp
	rjmp race_cache_end
not_last_segment:
	ldd temp1, Y + 2
	ldd temp, Y + 3
	sts cur_segment_length_h_addr, temp1
	sts cur_segment_length_l_addr, temp
	lsr temp1
	ror temp
	sts accept_turn_distance_h_addr, temp1
	sts accept_turn_distance_l_addr, temp

	ldi ZL, low(turn_speed_table<<1)
	ldi ZH, high(turn_speed_table<<1)
	ldd temp1, Y + 4 ; inner(0) / outer(1) turn
	ldd temp, Y + 5 ; antal segmenter (1 til 5)
	dec temp ; (0 til 4)
	lsl temp ; (0 til 8)
	add temp1, temp
	add ZL, temp1
	ldi temp, 0
	adc ZH, temp
	lpm temp, Z
	sts next_turn_speed_addr, temp
	get_kin_energy [temp]
	sts next_turn_kin_energy_addr, temp

	rjmp race_cache_end
race_cache_turn:
	ldi temp, race_segment_turn
	sts race_cur_segment_type_addr, temp

	ldd temp1, Y + 2
	ldd temp, Y + 3
	sts cur_segment_length_h_addr, temp1
	sts cur_segment_length_l_addr, temp
race_cache_end:

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop ZL
	pop ZH
	pop YL
	pop YH
	ret

race_main:
	push dh
	push dl
	push R1
	push R0
	push temp1
	push temp
	in temp, SREG
	push temp

	lds temp, race_cur_segment_type_addr
	cpi temp, race_segment_straight
	breq race_main_straight
	rjmp race_main_turn
race_main_straight:
	lds temp, has_started_braking_addr
	cpi temp, 1
	brne check_if_we_should_brake
	rjmp already_braking
check_if_we_should_brake:
	phys_speed [temp]
	get_kin_energy [temp]
	lds temp1, next_turn_kin_energy_addr
	sub temp, temp1
	brcs race_main_straight_end ; not driving faster, than the turn speed
	ldi temp1, start_brake_length_constant
	mul temp, temp1
	lsr R1
	ror R0
	lsr R1
	ror R0
	lsr R1
	ror R0
	lsr R1
	ror R0 ; Bremsedistancen ligger nu i R1:R0
	get_dis [temp1, temp]
	lds dl, cur_segment_length_l_addr
	lds dh, cur_segment_length_h_addr
	sub dl, temp
	sbc dh, temp1 ; Længden til næste sving ligger nu i dh:dl
	sub dl, R0
	sbc dh, R1
	brcc not_time_to_brake
	lds temp, next_turn_speed_addr
	set_control_speed [temp]
	send_bt_byte [1]
	send_bt_byte [temp]
	ldi temp, 1
	sts has_started_braking_addr, temp
already_braking:
not_time_to_brake:
race_main_straight_end:
	rjmp race_main_end
race_main_turn:
	get_dis [temp1, temp]
	lds dh, cur_segment_length_h_addr
	lds dl, cur_segment_length_l_addr
	sub dl, temp
	sbc dh, temp1
	brcc not_time_to_accelerate
	set_control_speed [straight_control_speed]
	setelemag [0]
	rcall race_next_segment
not_time_to_accelerate:
race_main_end:

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop R0
	pop R1
	pop dl
	pop dh
	ret

race_turn_detected:
	push dh
	push dl
	push temp1
	push temp
	in temp, SREG
	push temp

	lds temp, race_cur_segment_type_addr
	cpi temp, race_segment_straight
	brne race_turn_det_already_in_turn

	get_dis [temp1, temp]
	lds dh, accept_turn_distance_h_addr
	lds dl, accept_turn_distance_l_addr
	sub dl, temp
	sbc dh, temp1
	brcc race_turn_det_dont_accept
	setelemag [elemag_power]
	rcall race_next_segment
race_turn_det_dont_accept:
race_turn_det_already_in_turn:
	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop dl
	pop dh
	ret


race_file_end:
