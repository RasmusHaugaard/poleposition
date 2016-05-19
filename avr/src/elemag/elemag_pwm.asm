;PWM opsætning.  (s. 561)
;Vores Elektromagnets PWM er sat på PB3, så vi bruger Timer0 til PWM og TCCR0 registeret
;Den sammenligner timer0(TCNT0) og OCR0.
;Vi kan så styre dutycycle med OCR0.
;Eks. out OCR2, 255/4 for 25% dutycycle
.filedef temp = R16

push temp
ldi temp, DDRB
ori temp, (1<<PB3)
out DDRB, temp
		;PWM - Phase Correct------------  clear on match ------  pwm clock
ldi temp, (0<<WGM21) | (1<<WGM20) | (1<<COM21) | (0<<COM20) | (0<<CS22) | (0<<CS21) | (0<<CS20)
out TCCR0, temp
ldi temp, 0
out OCR0, temp

.macro setelemag
ERROR: Skal kaldes med argument
.endm

.macro	setelemag_8	;tager adresse til gpr
	out OCR0, @0	;og skriver gpr til OCR2
.endm

.macro	setelemag_i	;tager konstant
	push temp
	ldi temp, @0
	out OCR0, temp
	pop temp
.endm
