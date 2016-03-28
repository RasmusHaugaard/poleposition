;=====ISR Initalisering=====
sei					;tilader global interrupt
ldi R16, 1<<ISC2	;externt interrupt trigges ved stigning
out MCUCSR, R16		;..