;PWM opsætning.  (s. 561)
;Vores PWM er sat på PD7, så vi bruger Timer2 til PWM og TCCR2 registeret
;Den sammenligner timer2(TCNT2) og OCR2.
;Vi kan så styre dutycycle med OCR2.
;Eks. out OCR2, 255/4 for 25% dutycycle
ldi R16, DDRD
ori R16, (1<<PD7)
out DDRD, R16
		;PWM - Phase Correct------------  clear on match ------  pwm clock
ldi R16, (0<<WGM21) | (1<<WGM20) | (1<<COM21) | (0<<COM20) | (1<<CS22) | (0<<CS21) | (1<<CS20)
out TCCR2, R16
ldi R16, 0
out OCR2, R16

.macro setspeed
ERROR skal kaldes med argument
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
