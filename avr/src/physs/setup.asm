.equ old_time_hh = addr
.set addr = addr + 1
.equ old_time_h = addr	;gamle timer v�rdi (high bite)
.set addr = addr + 1
.equ old_time_l = addr	;gamle timer v�rdi (low bite)
.set addr = addr + 1
.equ dif_time = addr
.set addr = addr + 1
.equ dis_tik_l = addr	;Register som inkrimenters for hver motor tik (low bite)
.set addr = addr + 1
.equ dis_tik_h = addr	;Register som inkrimenters for hver motor tik (high bite)
.set addr = addr + 1

rcall reset_physs

rjmp physs_file_end

.macro	phys_speed
	.error "skal kaldes med argumenter"
.endm

.macro phys_speed_8		;Retunere tid mellem motor tiks
	call check_phys_speed_overflow
	lds @0, dif_time
.endm

check_phys_speed_overflow:
	push R16
	push R17
	push R18
	push R19
	push R20
	push R21
	in R21, SREG
	push R21

	lds R18, old_time_hh
	lds R17, old_time_h
	lds R16, old_time_l
	get_time_full [R21, R20, R19]
	sub R19, R16
	sbc R20, R17
	sbc R21, R18
	cpi R21, 0
	brne phys_speed_overflow
	cpi R20, 0
	brne phys_speed_overflow
	rjmp check_phys_speed_overflow_end
phys_speed_overflow:
	ldi R16, 0xFF
	sts dif_time, R16
check_phys_speed_overflow_end:
	pop R21
	out SREG, R21
	pop R21
	pop R20
	pop R19
	pop R18
	pop R17
	pop R16
	ret

.macro	get_dis
	.error "skal kaldes med argumenter"
.endm

.macro get_dis_8_8
	push R0
	in R0, SREG
	push R0

	cli
	lds @0, dis_tik_h	;retunere high byte
	lds @1, dis_tik_l	;retunere low byte

	pop R0
	out SREG, R0
	pop R0
.endm

reset_physs:
	rcall reset_physs_dis
	rcall reset_physs_speed
	ret
reset_physs_dis:
	push R16
	ldi R16, 0
	sts dis_tik_h, R16
	sts dis_tik_l, R16
	pop R16
	ret
reset_physs_speed:
	push R16
	ldi R16, 0
	sts old_time_h, R16	;nulstiller sidste timer værdi (high and low)
	sts old_time_l, R16
	ldi R16, 0xFF
	sts dif_time, R16
	pop R16
	ret

increment_dis:
	push R16
	in R16, SREG
	push R16
	push R17
	push R18
	push R19
	push R20
	push R21
	cli

	lds R18, old_time_hh
	lds R17, old_time_h
	lds R16, old_time_l
	get_time_full [R21, R20, R19]
	sts old_time_hh, R21
	sts old_time_h, R20		;kopier "nye timer" ind i "old time" (som referance ved n�ste interrupt)
	sts old_time_l, R19		;..
	sub R19, R16
	sbc R20, R17
	sbc R21, R18
	cpi R21, 0
	brne full_dif_time
	cpi R20, 0
	brne full_dif_time
	lds R16, dif_time
	lsr R16
	lsr R19
	add R19, R16
	rjmp after_full_dif_time
full_dif_time:
	ldi R19, 0xFF
after_full_dif_time:
	sts dif_time, R19
	lds R16, dis_tik_l	;kopier "dis_tek_l" til R16
	inc R16	;R16++ (inkrimentere)
	sts dis_tik_l, R16
	brne dis_no_overflow
	lds R17, dis_tik_h	;kopier "dis_tek_h" til R17
	inc R17	;R17++ (inkrimentere)
	sts dis_tik_h, R17		;kopier R17 ind i "dis_tik_h"
dis_no_overflow:
	pop R21
	pop R20
	pop R19
	pop R18
	pop R17
	pop R16
	out SREG, R16
	pop R16
	ret

physs_file_end:
