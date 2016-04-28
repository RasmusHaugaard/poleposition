;===================================
;========== Initalisering ==========
;===================================

.include "interrupt_adresser.asm"
.include "interrupt_initalisering.asm"
.include "stack_pointer.asm"
.include "Global_timer.asm"

.equ TCNT1HH = addr				;Opbevare v�rdi n�r timer1 overflower (24-bit register)
.set addr = addr + 1					

;===========================
;========== Macro ==========
;===========================

.macro get_time_full_8_8_8		;macro som retunere TCNT1HH, TCNT1H og TCNT1L.
;.if @0 = R16, @1, @2
;	ERROR  
;.endif
	push R16
	in R16, SREG
	push R16
	in R16, TIFR				;tjek overflow
	sbrs R16, TOV1				;skipper hvis TOV1 er sat
	rjmp TIME_GET
	rjmp CLEAR_TOV1				;clear TOV1 og inkrimentere TCNT1HH
TIME_GET_%:
	lds R16, TCNT1HH			
	in @2, TCNT1L				;Henter TCNT1L og TCNT1H
	in @1, TCNT1H				;..
	lds @0, TCNT1HH			;Tjekker om TCNT1HH har �ndret v�rdi i mellemtiden
	cpse R16, @0				;..
	rjmp TIME_GET_%				;Hvis TCNT1HH har �ndret v�rdi, hentes tid igen
	pop R16
	out SREG, R16
	pop R16
.endmacro


.macro get_time_hl_8_8			;macro som retunere TCNT1H og TCNT1L
	in @1, TCNT1L
	in @0, TCNT1H
.endmacro


.macro get_time_hh_8			;macro som retunere TCNT1HH
	lds @0, TCNT1HH
.endmacro

;=========================
;========== ISR ==========
;=========================

T1_OV_ISR:						;Interrupt(timer1 overflow)
	rcall CLEAR_TOV1
	reti						;retunere fra ISR
CLEAR_TOV1:						;inkrimentere HH og clear overflow flag
	lds R16, TCNT1HH			;kopier v�rdien fra TCNT1HH til R16
	inc R16						;R16 ++ (ligger 1 til R16)
	sts TCNT1HH, R16			;Kopier v�rdi fra R16 Til TCNT1HH
	ldi R16, 1<<TOV1			;clear overflow flag
	out TIFR, R16				;..
	ret							;retunere
	

EX2_ISR:						;Interrupt(kommer over lap-stregen)
	ldi R16, 0x00				;stopper timer1
	out TCCR1B, R16				;..
	in R18, TCNT1L				;ligger low bite fra timer i R18
	in R17, TCNT1H				;ligger high bite fra timer i R17
	lds R16, TCNT1HH			;ligger High High bite fra TCNT1HH i R16
	send_bt_byte[R16]			;send R16, R17, R18 til computer (24_bit register)
	send_bt_byte[R17]			;..
	send_bt_byte[R18]			;..
	ldi R16, 0x00				;nulstiller 24_bit timer register
	sts TCNT1HH, R16			;..
	out TCNT1H, R16				;..
	out TCNT1L, R16				;..
	ldi R16, 0b00000100			;starter timer1 (Normal - prescaler 256)
	out TCCR1B, R16				;..
	reti						;retunere fra ISR

;===========================
;========== Noter ==========
;===========================

;== start timer1 ==
;ldi R16, 0b00000100	;starter timer1 (Normal - prescaler 256)
;out TCCR1B, R16		;..


;== stop timer ==
;ldi R16, 0x00
;out TCCR1B, R16	;stopper Timer1