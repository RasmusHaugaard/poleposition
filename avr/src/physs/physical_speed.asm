;===================================
;========== Initalisering ==========
;===================================

;=====Timer0 (8-bit physucal_speed)=====
;=TCCR0(control)=
ldi R16, 0x00	;ligger v�rdien 0 i register R16
out TCCR0, R16	;stopper timer0
;=TCNT0(counter)=
ldi R16, 0x00	;ligger v�rdien 0 i register R16
out TCNT0, R16	;nulstiller timer0
;=TCCR0(control)=
ldi R16, 		;ligger v�rdien 0 i register R16
out TCCR0, R16	;starter timer0

.equ old_time_h = addr			;gamle timer v�rdi (high bite)
.set addr = addr + 1			;..
.equ old_time_l = addr			;gamle timer v�rdi (low bite)
.set addr = addr + 1			;..
.equ dif_time_h = addr			;sidste hastighed (high bite)
.set addr = addr + 1			;..
.equ dif_time_l = addr			;sidste hastighed (low bite)
.set addr = addr + 1			;..
.equ dis_tik_l = addr			;Register som inkrimenters for hver motor tik (low bite)
.set addr = addr + 1			;..
.equ dis_tik_h = addr			;Register som inkrimenters for hver motor tik (high bite)
.set addr = addr + 1			;..

ldi 0, R16						;nulstiller sidste timer v�rdi (high and low)
sts last_time_h, R16			;..
sts last_time_l, R16			;..
sts distance_tek, R16			;nulstiller distance register

;===========================
;========== Macro ==========
;===========================

.macro phys_speed_8_8		;Retunere tid mellem motor tiks
	push R16
	in R16, SREG
	push R16
	ldi R16, 0<<INT1		;Disabler interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
	lds @0, dif_time_h		;retunere high byte
	lds @1, dif_time_l		;retunere low byte
	ldi R16, 1<<INT1		;tilader interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
	pop R16
	out SREG, R16
	pop R16
.endmacro

.macro get_dis_hl_8_8
	push R16
	in R16, SREG
	push R16
	ldi R16, 0<<INT1		;Disabler interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
	ldi @0, dis_tik_h		;retunere high byte
	lds @1, dis_tik_l		;retunere low byte
	ldi R16, 1<<INT1		;tilader interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
	pop R16
	out SREG, R16
	pop R16
.endmacro

;=========================
;========== ISR ==========
;=========================

EX1_ISR:					;interrupt(motor tick)
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
	send_bt_byte [R19]		;sender low bite til pc
	send_bt_byte [R18]		;sender high bite til pc
	sts dif_time_h, R18		;gemmer forskellen mellem "ny" og "old" timer
	sts dif_time_l, R19		;..

	lds R16, dis_tik_l		;kopier "dis_tek_l" til R16
	inc R16					;R16++ (inkrimentere)
	brvc dis_no_overflow	;hvis forige overflowed, skal "dis_tek_h" inkrimenteres (branch if overflow cleared	)
	lds R17, dis_tik_h		;kopier "dis_tek_h" til R17
	inc R17					;R17++ (inkrimentere)
	sts dis_tik_h, R17		;kopier R17 ind i "dis_tik_h"
dis_no_overflow:
	sts distance_tek, R16	;Kopier R16 ind i "distance_tek"
	pop R16
	out SREG, R16
	pop R18
	pop R17
	pop R16
	reti					;retunere fra interrupt

;===========================
;========== Noter ==========
;===========================