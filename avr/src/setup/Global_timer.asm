;=====Timer (8-bit physucal_speed)=====
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
;=OCR1A(compare)=
;ldi R16, 0xF4	;ligger 62500 ind i R16 og R17 (16-bit)
;ldi R17, 0x24	;..
;out OCR1AH, R16 ;ligger high bite i compare register
;out OCR1AL, R17	;ligger low bite i compare register