rjmp turn_direction_to_inner_outer_file_end

turn_direction_to_inner_outer:

	lds l_inner, left_inner
	ldi XL, low(map_data_start_addr)
	ldi XH, high(map_data_start_addr)
	ldi turncnt, first_map_segment_count
	subi turncnt, 1
	lsr turncnt ; antallet af sving (segments - 1)/2
	adiw XH:XL, 4 ;addressen til første sving

turn_d_io_loop:
	cpi turncnt, 0
	breq turn_d_io_loop_end
	ld temp, x
	cpi temp, left_segment
	breq t_l_left_seg
	cpi temp, right_segment
	breq t_l_right_seg
	rjmp seg_turn_val_error
t_l_left_seg:

t_l_right_seg:

turn_d_io_loop_end:


	ret


seg_turn_val_error:
	setspeed [0]
	send_bt_byte [seg_turn_val_error_code]
	send_bt_byte [temp]
	delays [2]
	sei
	rjmp seg_turn_val_error

turn_direction_to_inner_outer_file_end:
