;PWM opsætning.  (s. 561)
;Vores PWM er sat på PD7, så vi bruger Timer2 til PWM og TCCR2 registeret
;Den sammenligner timer2(TCNT2) og OCR2.
;Vi kan så styre dutycycle med OCR2.
;Eks. out OCR2, 255 * 0.25 for 25% dutycycle
		;Fast PWM------------       PWM active high   PWM clk
ldi R16, (1<<WGM21) | (1<<WGM20) | (1<<COM22) | (1<<CS21) | (0<<CS20)
out TCCR2, R16


.macro setspeed
.endm

.macro	setspeed_8	;tager adresse til gpr
	out OCR2, @0	;og skriver gpr til OCR2
.endm

.macro	setspeed_i	;tager konstant
	push R16
	ldi R16, @0
	out OCR2, R16
	pop R16
.endm
