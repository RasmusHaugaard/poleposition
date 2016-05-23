.filedef temp = R16
.filedef h = R17
.filedef l = R18
.filedef segcnt = R19

jmp map_avg_file_end

average_map:
	push XH
	push XL
	push segcnt
	push h
	push l
	push temp
	in temp, SREG
	push temp

	ldi XL, low(map_data_start_addr)
	ldi XH, high(map_data_start_addr)
	lds segcnt, first_map_segment_count

segment_loop:
	adiw XH:XL, 2
	ld h, X+
	ld l, X
	ldi temp, map_round_set_count
rotate_loop:
	cpi temp, 0
	breq rotate_done
	lsr h
	ror l
	dec temp
	rjmp rotate_loop
rotate_done:
	dec XL
	ldi temp, 0
	sbc XH, temp
	st X+, h
	st X+, l
	dec segcnt
	brne segment_loop

	pop temp
	out SREG, temp
	pop temp
	pop l
	pop h
	pop segcnt
	pop XL
	pop XH
	ret


map_avg_file_end:
