.filedef val = R16
.filedef cnt_l = R17
.filedef cnt_h = R18

rjmp map_clearer_file_end

map_clearer:
	push val
	in val, SREG
	push val
	push cnt_l
	push cnt_h
	push XL
	push XH

	ldi val, 0
	ldi XL, low(map_data_start_addr)
	ldi XH, high(map_data_start_addr)
	ldi cnt_l, low(map_data_length)
	ldi cnt_h, high(map_data_length)
map_clear_loop:
	st X+, val
	dec cnt_l
	brne map_clear_loop
	cpi cnt_l, 0
	breq map_clear_end
	dec cnt_l
	brne map_clear_loop
map_clear_end:

	pop XH
	pop XL
	pop cnt_h
	pop cnt_l
	pop val
	out SREG, val
	pop val
	ret

map_clearer_file_end:
