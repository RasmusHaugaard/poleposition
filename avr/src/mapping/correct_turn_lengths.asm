;her antages det, længden fra starten af et sving til starten af næste sving er præcist målt
.filedef turncnt = R16
.filedef innerouter = R17
.filedef turn_segments = R18
.filedef meassured_length_h = R19
.filedef meassured_length_l = R20
.filedef turnlength_h = R21
.filedef turnlength_l = R22
.filedef next_straight_length_h = R23
.filedef next_straight_length_l = R24

rjmp correct_turn_lengths_file_end

correct_turn_lengths:
	push turncnt
	push innerouter
	push turn_segments
	push meassured_length_h
	push meassured_length_l
	push turnlength_h
	push turnlength_l
	push next_straight_length_h
	push next_straight_length_l
	push YH
	push YL
	in YL, SREG
	push YL

	ldi YL, low(map_data_start_addr)
	ldi YH, high(map_data_start_addr)
	lds turncnt, first_map_segment_count
	dec turncnt
	lsr turncnt ;antal sving (seg_count - 1)/2
	adiw YH:YL, 4 ;første sving

corr_turn_length_loop:
	cpi turncnt, 0
	breq after_corr_turn_length_loop
	ld innerouter, Y
	ldd turn_segments, Y+1
	ldd meassured_length_h, Y+2
	ldd meassured_length_l, Y+3
	cpi innerouter, innerturn
	brne corr_t_l_outer
	ldi turnlength_l, innerlength
	rjmp corr_t_l_got_length
	corr_t_l_outer:
	ldi turnlength_l, outerlength
corr_t_l_got_length:
	mul turnlength_l, turn_segments
	mov turnlength_l, R0
	mov turnlength_h, R1
	std Y+2, turnlength_h
	std Y+3, turnlength_l
	sub meassured_length_l, turnlength_l
	sbc meassured_length_h, turnlength_h
	ldd next_straight_length_h, Y+6
	ldd next_straight_length_l, Y+7
	add next_straight_length_l, meassured_length_l
	adc next_straight_length_h, meassured_length_h
	std Y+6, next_straight_length_h
	std Y+7, next_straight_length_l

	dec turncnt
	adiw YH:YL, 8 ; næste sving
	rjmp corr_turn_length_loop
after_corr_turn_length_loop:

	pop YL
	out SREG, YL
	pop YL
	pop YH
	pop next_straight_length_l
	pop next_straight_length_h
	pop turnlength_l
	pop turnlength_h
	pop meassured_length_l
	pop meassured_length_h
	pop turn_segments
	pop innerouter
	pop turncnt
	ret


correct_turn_lengths_file_end:
