.equ old_time_h = addr	;gamle timer v�rdi (high bite)
.set addr = addr + 1
.equ old_time_l = addr	;gamle timer v�rdi (low bite)
.set addr = addr + 1
.equ dif_time_h = addr	;sidste hastighed (high bite)
.set addr = addr + 1
.equ dif_time_l = addr	;sidste hastighed (low bite)
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

.macro phys_speed_8_8		;Retunere tid mellem motor tiks
	push R16
	in R16, SREG
	push R16

	ldi R16, 0<<INT1	;Disabler interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16
	lds @0, dif_time_h	;retunere high byte
	lds @1, dif_time_l	;retunere low byte
	ldi R16, 1<<INT1	;tilader interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16

	pop R16
	out SREG, R16
	pop R16
.endm

.macro	get_dis
	.error "skal kaldes med argumenter"
.endm

.macro get_dis_8_8
	push R16
	in R16, SREG
	push R16

	cli
	lds @0, dis_tik_h	;retunere high byte
	lds @1, dis_tik_l	;retunere low byte

	pop R16
	out SREG, R16
	pop R16
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
	pop R16
	ret

increment_dis:
	push R16
	push R17
	push R18
	in R16, SREG
	push R16
	get_time_hl [R18, R19]	;kopier "nye timer" til R18 og R19
	lds R16, old_time_h		;koper "old timer" fra adresse til R16 og R17
	lds R17, old_time_l		;..
	sts old_time_h, R18		;kopier "nye timer" ind i "old time" (som referance ved n�ste interrupt)
	sts old_time_l, R19		;..
	sub R19, R17			;(low bite) Tr�kker "old timer" (R17) fra den nye "nye timer" (R19)
	sbc R18, R16			;(High bite) Tr�kker "old timer" (R16) fra den nye "nye timer" (R18)
	sts dif_time_h, R18		;gemmer forskellen mellem "ny" og "old" timer
	sts dif_time_l, R19		;..
	lds R16, dis_tik_l		;kopier "dis_tek_l" til R16
	inc R16					;R16++ (inkrimentere)
	sts dis_tik_l, R16
	brvc dis_no_overflow	;hvis forige overflowed, skal "dis_tek_h" inkrimenteres (branch if overflow cleared	)
	lds R17, dis_tik_h		;kopier "dis_tek_h" til R17
	inc R17					;R17++ (inkrimentere)
	sts dis_tik_h, R17		;kopier R17 ind i "dis_tik_h"
dis_no_overflow:
	pop R16
	out SREG, R16
	pop R18
	pop R17
	pop R16
	ret

physs_file_end:
