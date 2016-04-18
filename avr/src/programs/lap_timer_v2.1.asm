;===================================
;========== Initalisering ==========
;===================================
.def TCNT1HH=			;Opbevare værdi når timer1 overflower (24-bit register) <------------------------- skal have en lokation i sram



;===========================
;========== Macro ==========
;===========================



;=========================
;========== ISR ==========
;=========================

T1_CM_ISR:				;Interrupt(timer1 compare flag OCF1A)  <---------- skal laves om til ISC når timer 1 overflower
	lds R16, TCNT1HH	;kopier værdien fra TCNT1HH til R16
	inc R16				;R16 ++ (ligger 1 til R16)
	sts TCNT1HH, R16	;kopier værdi fra R16 til TCNT1HH
	ldi R16, 1<<TOV1	;clear TOV1 (overflow) flag				<----------- tjek om overflow flag skal clears når det er isr rutine
	out TIFR, R16		;..
	reti				;retunere fra ISR

EX2_ISR:				;Interrupt(kommer over lap-stregen)
	ldi R16, 0x00		;stopper timer1
	out TCCR1B, R16		;..
	in R18, TCNT1L		;ligger low bite fra timer i R18
	in R17, TCNT1H		;ligger high bite fra timer i R17
	lds R16, TCNT1HH	;ligger High High bite fra TCNT1HH i R16
	send_bt_byte[R16]	;send R16, R17, R18 til computer (24_bit register)
	send_bt_byte[R17]	;..
	send_bt_byte[R18]	;..
	ldi R16, 0x00		;nulstiller 24_bit timer register
	sts TCNT1HH, R16	;..
	out TCNT1H, R16		;..
	out TCNT1L, R16		;..
	ldi R16, 0b00000100	;starter timer1 (Normal - prescaler 256)
	out TCCR1B, R16		;..
	reti				;retunere fra ISR

;===========================
;========== Noter ==========
;===========================

;== start timer1 ==
;ldi R16, 0b00000100	;starter timer1 (Normal - prescaler 256)
;out TCCR1B, R16		;..


;== stop timer ==
;ldi R16, 0x00
;out TCCR1B, R16	;stopper Timer1