.filedef temp = R31
.filedef r = R16
.filedef cl = R24
.filedef ch = R25

.equ kin_div_constant = 11500

rjmp kin_energy_file_end

.macro get_kin_energy
	.error "Skal kaldes med argument"
.endm

.macro get_kin_energy_8
	push temp
	in temp, SREG
	push temp

	mov temp, @0
	rcall get_kin_energy
	mov @0, temp

	pop temp
	out SREG, temp
	pop temp
.endm

get_kin_energy:
	cpi temp, 45
	brlo full_kin_energy
not_full_kin_energy:
	push ch
	push cl
	push r
	push R1
	push R0
	ldi ch, high(kin_div_constant)
	ldi cl, low(kin_div_constant)
	ldi r, 0
div_loop:
	inc r
	sub cl, temp
	sbci ch, 0
	brcc div_loop
	dec r
	mul r, r
	mov temp, R1
	pop R0
	pop R1
	pop r
	pop cl
	pop ch
	ret
full_kin_energy:
	ldi temp, 255
	ret


kin_energy_file_end:
