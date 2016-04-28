;=====Timer0 (8-bit physucal_speed)=====
;=TCCR0(control)=
ldi R16, 0x00	;ligger værdien 0 i register R16
out TCCR0, R16	;stopper timer0
;=TCNT0(counter)=
ldi R16, 0x00	;ligger værdien 0 i register R16
out TCNT0, R16	;nulstiller timer0
;=TCCR0(control)=
ldi R16, 		;ligger værdien 0 i register R16
out TCCR0, R16	;starter timer0


;=====Timer1 (16-bit Lab_timer)=====

;=TCCR1A(control)=
ldi R16, 0x00	;ligger værdien 0 i R16
out TCCR1A, R16	;slår funktioner fra i TCCR1A
out TCCR1B, R16 ;stopper timer1
;=TCNT1(counter)=
ldi R16, 0x00	;ligger værdien 0, i R16
out TCNT1H, R16	;nulstiller timer1 high bite
out TCNT1L, R16	;nulstiller timer1 low bite