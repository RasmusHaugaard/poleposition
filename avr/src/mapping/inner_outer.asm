;Skal mappe højre-venstre til indre-ydre
;For hvert sving, læg de 2 absolutte afvigelser (hvis det var indre/ydre) til de 2 samlede afvigelser.
;til sidst bestem mapningen ved at sammenligne de to afvigelser

.equ innerlength = 64
.equ outerlength = 84

.equ innnerouter_addr = addr
.set addr = addr + 1
.equ left_inner = 0
.equ right_inner = 1

.filedef err_left_inner_h = R12
.filedef err_left_inner_l = R13
.filedef err_right_inner_h = R14
.filedef err_right_inner_l = R15
.filedef temp = R16
.filedef temp1 = R17
.filedef l = R18
.filedef h = R19
.filedef cnt = R20

inner_outer:
	push R1
	push R0
	push err_left_inner_h
	push err_left_inner_l
	push err_right_inner_h
	push err_right_inner_l
	push h
	push l
	push cnt
	push temp1
	push temp
	in temp, SREG
	push temp

	lds cnt, first_map_segment_count
	ldi temp, 0
	mov err_left_inner_h, temp
	mov err_left_inner_l, temp
	mov err_right_inner_h, temp
	mov err_right_inner_l, temp

	ldi XH, high(map_data_start_addr)
	ldi XL, lwo(map_data_start_addr)

nextsegment: ; (første segment er lige)
	adiw X, 4
sum_loop:
	dec cnt ; (sidste segment er lige)
	breq sum_done
	ld temp, X ; segment type
	cpi temp, straight_segment
	breq nextsegment
	adiw X, 1
	ld temp1, X+ ; antal sving segmenter i svinget
	ld h, X+
	ld l, X+
	cpi temp, right_segment
	brne is_left_segment
is_right_segment:
	ldi temp, innerlength
	mul temp1, temp ; R1:R0 indeholder nu den teoretiske længde, hvis det er et indre sving
	rcall abs_error_hl_R1R0
	add err_right_inner_l, R0
	adc err_right_inner_h, R1
	ldi temp, outerlength
	mul temp1, temp
	rcall abs_error_hl_R1R0
	add err_left_inner_l, R0
	adc err_right_inner_h, R1
	rjmp sum_loop
is_left_segment:
	ldi temp, innerlength
	mul temp1, temp ; R1:R0 indeholder nu den teoretiske længde, hvis det er et indre sving
	rcall abs_error_hl_R1R0
	add err_left_inner_l, R0
	adc err_right_inner_h, R1
	ldi temp, outerlength
	mul temp1, temp
	rcall abs_error_hl_R1R0
	add err_right_inner_l, R0
	adc err_right_inner_h, R1
	rjmp sum_loop
sum_done:
	cpi err_right_inner_h, err_left_inner_h
	breq comparelow
	brlo is_right_inner
	rjmp is_left_inner
comparelow:
	cpi err_right_inner_l, err_left_inner_l
	brlo is_right_inner
	rjmp is_left_inner
is_right_inner:
	ldi temp, right_inner
	sts innnerouter_addr, temp
	rjmp inner_outer_end
is_left_inner:
	ldi temp, left_inner
	sts innnerouter_addr, temp
	rjmp inner_outer_end
inner_outer_end:
	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop cnt
	pop l
	pop h
	pop err_right_inner_l
	pop err_right_inner_h
	pop err_left_inner_l
	pop err_left_inner_h
	pop R0
	pop R1
	ret

abs_error_hl_R1R0:
	push h
	push l
	sub l, R0
	sbc h, R1
	brcc error_is_abs
	com h
	neg l
	sbci h, 0xFF
error_is_abs:
	mov R0, l
	mov R1, h
	pop l
	pop h
	ret
