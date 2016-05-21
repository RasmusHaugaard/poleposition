;===================================
;========== Initalisering ==========
;===================================

.set saved_pc = PC
.org 0x12		;adresse for timer1 overflow (interrupt vektor table)
	jmp T1_OV_ISR	;adresse med mere plads
.org saved_pc

;=== Timer1 overflow interrupt ===
in R16, TOV1
andi R16, 1<<TOV1	;tilader interrupt ved timer1 overflow
out TIMSK, R16		;..

rcall reset_lap_timer
jmp lapt_file_end

;=== define ===
.equ TCNT1HH = addr				;Opbevare v�rdi n�r timer1 overflower (24-bit register)
.set addr = addr + 1

;===========================
;========== Macro ==========
;===========================

.macro get_time_full
	Error "get_time_full"
.endm

.macro get_time_full_8_8_8		;macro som retunere TCNT1HH, TCNT1H og TCNT1L.
;.if @0 = R16, @1, @2
;	ERROR
;.endif
	push R16
	in R16, SREG
	push R16
	in R16, TIFR				;tjek overflow
	sbrs R16, TOV1				;skipper hvis TOV1 er sat
	rjmp PC + 3
	call T1_OV_ISR_CLEAR				;clear TOV1 og inkrimentere TCNT1HH
; PC + 3:
	lds R16, TCNT1HH
	in @2, TCNT1L				;Henter TCNT1L og TCNT1H
	in @1, TCNT1H				;..
	lds @0, TCNT1HH				;Tjekker om TCNT1HH har �ndret v�rdi i mellemtiden
	cpse R16, @0				;..
	rjmp TIME_GET_%				;Hvis TCNT1HH har �ndret v�rdi, hentes tid igen
	pop R16
	out SREG, R16
	pop R16
.endm

.macro get_time_hl
	Error "get_time_hl"
.endm

.macro get_time_hl_8_8			;macro som retunere TCNT1H og TCNT1L
	push R16
	in R16, SREG
	push R16
	in @1, TCNT1L
	in @0, TCNT1H
	pop R16
	out SREG, R16
	pop R16
.endm

.macro get_time_hh
	Error "get_time_hh"
.endm

.macro get_time_hh_8			;macro som retunere TCNT1HH
	push R16
	in R16, SREG
	push R16
	lds @0, TCNT1HH
	pop R16
	out SREG, R16
	pop R16
.endm

;=========================
;========== ISR ==========
;=========================

T1_OV_ISR:						;Interrupt(timer1 overflow)
	rcall T1_OV_ISR_CLEAR
	reti						;retunere fra ISR

T1_OV_ISR_CLEAR:
	push R16
	push R17
	in R16, SREG
	push R16
	lds R16, TCNT1HH			;kopier v�rdien fra TCNT1HH til R16
	inc R16						;R16 ++ (ligger 1 til R16)
	sts TCNT1HH, R16			;Kopier v�rdi fra R16 Til TCNT1HH
	ldi R16, 1<<TOV1			;clear overflow flag
	out TIFR, R16				;..
	pop R16						;reset registre til oprindelige v�rdi
	out SREG, R16				;..
	pop R17						;..
	pop R16						;..
	ret							;retunere

lap_finished:
	push R16					;gemmer registres v�rdi
	push R17					;..
	push R18					;..
	in R16, SREG				;..
	push R16					;..
	ldi R16, 0x00				;stopper timer1
	out TCCR1B, R16				;..
	in R18, TCNT1L				;ligger low bite fra timer i R18
	in R17, TCNT1H				;ligger high bite fra timer i R17
	lds R16, TCNT1HH			;ligger High High bite fra TCNT1HH i R16
	send_bt_byte [255]
	send_bt_byte [R16]			;send R16, R17, R18 til computer (24_bit register)
	send_bt_byte [R17]			;..
	send_bt_byte [R18]			;..
	rcall reset_lap_timer
	pop R16						;reset registre til oprindelige v�rdi
	out SREG, R16				;..
	pop R18						;..
	pop R17						;..
	pop R16						;..
	ret							;retunere fra ISR

reset_lap_timer:
	push R16
	ldi R16, 0x00	;ligger v�rdien 0 i R16
	out TCCR1A, R16	;sl�r funktioner fra i TCCR1A
	out TCCR1B, R16 ;stopper timer1
	ldi R16, 0x00				;nulstiller 24_bit timer register
	sts TCNT1HH, R16			;..
	out TCNT1H, R16				;..
	out TCNT1L, R16				;..
	ldi R16, 0b00000100			;starter timer1 (Normal - prescaler 256)
	out TCCR1B, R16				;..
	pop R16
	ret

lapt_file_end:

;===========================
;========== Noter ==========
;===========================

;== start timer1 ==
;ldi R16, 0b00000100	;starter timer1 (Normal - prescaler 256)
;out TCCR1B, R16		;..


;== stop timer ==
;ldi R16, 0x00
;out TCCR1B, R16	;stopper Timer1
