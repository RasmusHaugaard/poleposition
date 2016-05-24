.filedef temp = R16
.filedef inner = R17
.filedef turncnt = R18

.equ innerturn = 30
.equ outerturn = 40

rjmp turn_direction_to_inner_outer_file_end

turn_direction_to_inner_outer:
	push XH
	push XL
	push inner
	push turncnt
	push temp
	in temp, SREG
	push temp

	lds inner, innnerouter_addr
	ldi XL, low(map_data_start_addr)
	ldi XH, high(map_data_start_addr)
	lds turncnt, first_map_segment_count
	subi turncnt, 1
	lsr turncnt ; antallet af sving (segments - 1)/2
	adiw XH:XL, 4 ;addressen til første sving

turn_d_io_loop:
	cpi turncnt, 0
	breq after_turn_d_io_loop
	ld temp, X
	cpi temp, left_segment
	breq t_l_left_seg
	cpi temp, right_segment
	breq t_l_right_seg
	rjmp seg_turn_val_error
t_l_left_seg:
	cpi inner, left_inner
	breq store_inner
	rjmp store_outer
t_l_right_seg:
	cpi inner, right_inner
	breq store_inner
	rjmp store_outer
store_inner:
	ldi temp, innerturn
	st X, temp
	rjmp turn_d_io_loop_end
store_outer:
	ldi temp, outerturn
	st X, temp
turn_d_io_loop_end:
	dec turncnt
	adiw XH:XL, 8; adresse til næste sving
	rjmp turn_d_io_loop
after_turn_d_io_loop:

	pop temp
	out SREG, temp
	pop temp
	pop turncnt
	pop inner
	pop XL
	pop XH
	ret


seg_turn_val_error:
	setspeed [0]
	send_bt_byte [seg_turn_val_error_code]
	send_bt_byte [temp]
	delays [2]
	sei
	rjmp seg_turn_val_error

turn_direction_to_inner_outer_file_end:
