.filedef temp = R16
.filedef temp1 = R17

.equ gyr_integration_l_addr = addr
.set addr = addr + 1
.equ gyr_integration_h_addr = addr
.set addr = addr + 1

.equ one_turn_max = 40
.equ two_turns_max = 75
.equ three_turns_max = 105
.equ four_turns_max = 140

rjmp gyr_integrate_file_end

start_gyr_integration:
	push temp
	ldi temp, 0
	sts gyr_integration_h_addr, temp
	sts gyr_integration_l_addr, temp
	pop temp
	ret

gyr_integrate:
	push temp
	in temp, SREG
	push temp
	push temp1

	lds temp, gyr_integration_l_addr
	lds temp1, cur_gyr_val_addr
	cpi temp1, 0
	brge gyr_int_positiv
	neg temp1
	cpi temp1, 0
	brge gyr_int_positiv
	ldi temp1, 127
gyr_int_positiv:
	add temp, temp1
	sts gyr_integration_l_addr, temp
	brcc gyr_int_no_overflow
	lds temp1, gyr_integration_h_addr
	inc temp1
	sts gyr_integration_h_addr, temp1
gyr_int_no_overflow:
	pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret

gyr_integrate_store:
	push temp1
	in temp1, SREG
	push temp1
	push temp

	lds temp, gyr_integration_l_addr
	lds temp1, gyr_integration_h_addr
	lsl temp
	rol temp1
	lsl temp
	rol temp1
	lsl temp
	rol temp1

	ldi temp, 1
	cpi temp1, one_turn_max
	brlo gyr_store_end
	ldi temp, 2
	cpi temp1, two_turns_max
	brlo gyr_store_end
	ldi temp, 3
	cpi temp1, three_turns_max
	brlo gyr_store_end
	ldi temp, 4
	cpi temp1, four_turns_max
	brlo gyr_store_end
	ldi temp, 5
	gyr_store_end:
	st X+, temp

	pop temp
	pop temp1
	out SREG, temp1
	pop temp1
	ret

gyr_integrate_file_end:
