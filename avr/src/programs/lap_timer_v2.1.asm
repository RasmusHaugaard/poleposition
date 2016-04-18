;===================================
;========== Initalisering ==========
;===================================

.def TCNT1HH=					;Opbevare værdi når timer1 overflower (24-bit register) <------------------------- skal have en lokation i sram

;===========================
;========== Macro ==========
;===========================

.macro get_time_full			;macro som retunere TCNT1HH, TCNT1H og TCNT1L.
retry_get_time:
	lds R16, TCNT1HH			
	in R17, TCNT1L
	in R18, TCNT1H
	lds R19, TCNT1HH			;Tjekker om TCNT1HH har ændret værdi i mellemtiden
	cpse R16, R19				;..
	rjmp retry_get_time			;Hvis TCNT1HH har ændret værdi, hentes tid igen
	mov	@0, R19					;HH
	mov	@1, R18					;H
	mov @2,	R17					;L
.endmacro


.macro get_time_hl				;macro som retunere TCNT1H og TCNT1L
	in @1, TCNT1L
	in @0, TCNT1H
.endmacro


.macro get_time_hh				;macro som retunere TCNT1HH
	lds @0, TCNT1HH
.endmacro

;=========================
;========== ISR ==========
;=========================

T1_OV_ISR:						;Interrupt(timer1 overflow)
	lds R16, TCNT1HH			;kopier værdien fra TCNT1HH til R16
	inc R16						;R16 ++ (ligger 1 til R16)
	sts TCNT1HH, R16			;Kopier værdi fra R16 Til TCNT1HH
	reti						;retunere fra ISR

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