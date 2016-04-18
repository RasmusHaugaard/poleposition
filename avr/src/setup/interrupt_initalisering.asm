;=====ISR Initalisering=====
sei					;tilader global interrupt

;=== extern interrupt 2 ==
ldi R16, 1<<INT2	;tillader externt interrupt 2 (Port B, pin 2)
out GICR, R16		;..
ldi R16, 1<<ISC2	;Opsættes til at trigge ved puls stigning 
out MCUCSR, R16		;..

;=== extern interrupt 1 ==
ldi R16, 1<<INT1	;tilader interrupt ved externt trigger 1 (Port D, pin 3)
out GICR, R16		;..
ldi R16, 1<<ISC11	;opsætter til at trigge ved puls stigning
out	MCUCR, R16		;..
ldi R16, 1<<ISC10	;..
out MCUCR, R16		;..

;=== Timer1 overflow interrupt ===
ldi R16, 1<<TOV1	;tilader interrupt ved timer1 overflow
out TIMSK, R16		;..