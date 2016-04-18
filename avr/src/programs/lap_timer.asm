T1_CM_ISR:			;Interrupt(timer1 compare flag OCF1A)
	ldi R16, 4		;ligger 4sekunter til lap_register (R30)
	add R30, R16	;..
	reti			;retunere fra ISR

EX2_ISR:			;Interrupt(kommer over lap-stregen)
	ldi R16, 0x00	;stopper timer1
	out TCCR1B, R16	;..
	send_bt_byte[R30]	;send lap_register (R30) til computer (enhed er sekunder)
	in R16, TCNT1H	;ligger high bite fra timer i R16					=====send "rest" v�rdi i timer-register (enhed er counts "1 count = 0.000064 sekunder")=====
	in R17, TCNT1L	;ligger low bite fra timer i R17
	send_bt_byte[R16]	;send R16 og R17 til computer
	send_bt_byte[R17]	;..
	ldi R30, 0x00	;nulstiller lab_register (R30)
	ldi R16, 0x00	;nulstiller timer1
	out TCNT1H, R16	;nulstiller timer1 high bite
	out TCNT1L, R16	;nulstiller timer1 low bite
	ldi R16, 0x0D	;starter timer1 (CTC - prescaler 1024)
	out TCCR1B, R16	;..
	reti			;retunere fra ISR

;==start timer(CTC - prescaler 1024)==
;ldi R16,0x0D		;starter timer1 (CTC - prescaler 1024)
;out TCCR1B, R16	;..

;==stop timer==
;ldi R16, 0
;out TCCR1B, R16	;stopper Timer1