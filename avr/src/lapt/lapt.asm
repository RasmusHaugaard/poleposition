;===================================
;========== Initalisering ==========
;===================================

.include "src/setup/stack_pointer.asm"

;=====Timer1 (16-bit Lab_timer)=====
;=TCCR1A(control)=
ldi R16, 0x00	;ligger værdien 0 i R16
out TCCR1A, R16	;slår funktioner fra i TCCR1A
out TCCR1B, R16 ;stopper timer1
;=TCNT1(counter)=
ldi R16, 0x00	;ligger værdien 0, i R16
out TCNT1H, R16	;nulstiller timer1 high bite
out TCNT1L, R16	;nulstiller timer1 low bite

;=====ISR Initalisering=====
sei					;tilader global interrupt

;=== extern interrupt 2 ==
ldi R16, 1<<INT2	;tillader externt interrupt 2 (Port B, pin 2)
out GICR, R16		;..
ldi R16, 1<<ISC2	;Opsættes til at trigge ved puls stigning 
out MCUCSR, R16		;..

;=== extern interrupt 1 ==
;ldi R16, 1<<INT1	;tilader interrupt ved externt trigger 1 (Port D, pin 3)
;out GICR, R16		;..
;ldi R16, 1<<ISC11	;opsætter til at trigge ved puls stigning
;out	MCUCR, R16		;..
;ldi R16, 1<<ISC10	;..
;out MCUCR, R16		;..

;=== Timer1 overflow interrupt ===
ldi R16, 1<<TOV1	;tilader interrupt ved timer1 overflow
out TIMSK, R16		;..

;=== ISR vector table ===
.org 0			;start adresse
jmp main		;adresse med mere plads

.org 0x12		;adresse for timer1 overflow (interrupt vektor table)
jmp T1_OV_ISR	;adresse med mere plads

.org 0x06		;adresse for extern interrupt 2 (Port B, pin 2)
jmp EX2_ISR		;adresse med mere plads

.org 0x04		;adresse for extern interrupt 1 (Port D, pin 3)
jmp EX1_ISR		;adresse med mere plads

;=== define ===
.equ TCNT1HH = addr				;Opbevare værdi når timer1 overflower (24-bit register)
.set addr = addr + 1					

;===========================
;========== Macro ==========
;===========================

.macro get_time_full
	Error "get_time_full"
.endmacro

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
	lds @0, TCNT1HH				;Tjekker om TCNT1HH har ændret værdi i mellemtiden
	cpse R16, @0				;..
	rjmp TIME_GET_%				;Hvis TCNT1HH har ændret værdi, hentes tid igen
	pop R16
	out SREG, R16
	pop R16
.endmacro

.macro get_time_hl
	Error "get_time_hl"
.endmacro

.macro get_time_hl_8_8			;macro som retunere TCNT1H og TCNT1L
	push R16
	in R16, SREG
	push R16
	in @1, TCNT1L
	in @0, TCNT1H
	pop R16
	out SREG, R16
	pop R16
.endmacro

.macro get_time_hh
	Error "get_time_hh"
.endmacro

.macro get_time_hh_8			;macro som retunere TCNT1HH
	push R16
	in R16, SREG
	push R16
	lds @0, TCNT1HH
	pop R16
	out SREG, R16
	pop R16
.endmacro

;=========================
;========== ISR ==========
;=========================

T1_OV_ISR:						;Interrupt(timer1 overflow)
	push R16					;gemmer registres værdi
	push R17					;..
	in R16, SREG				;..
	push R16					;..
	rcall T1_OV_ISR_CLEAR
	reti						;retunere fra ISR
CLEAR_TOV1:						;inkrimentere HH og clear overflow flag
	push R16
	push R17
T1_OV_ISR_CLEAR:
	lds R16, TCNT1HH			;kopier værdien fra TCNT1HH til R16
	inc R16						;R16 ++ (ligger 1 til R16)
	sts TCNT1HH, R16			;Kopier værdi fra R16 Til TCNT1HH
	ldi R16, 1<<TOV1			;clear overflow flag
	out TIFR, R16				;..
	pop R16						;reset registre til oprindelige værdi
	out SREG, R16				;..
	pop R17						;..
	pop R16						;..
	ret							;retunere
	

EX2_ISR:						;Interrupt(kommer over lap-stregen)
	push R16					;gemmer registres værdi
	push R17					;..
	push R18					;..
	in R16, SREG				;..
	push R16					;..
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
	pop R16						;reset registre til oprindelige værdi
	out SREG, R16				;..
	pop R18						;..
	pop R17						;..
	pop R16						;..
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