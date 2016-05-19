;PWM opsætning.  (s. 561)
;Vores PWM er sat på PD7, så vi bruger Timer2 til PWM og TCCR2 registeret
;Den sammenligner timer2(TCNT2) og OCR2.
;Vi kan så styre dutycycle med OCR2.
;Eks. out OCR2, 255/4 for 25% dutycycle
.filedef temp = R16

push temp
ldi temp, DDRD
ori temp, (1<<PD7)
out DDRD, temp
		;PWM - Phase Correct------------  clear on match ------  pwm clock
ldi temp, (0<<WGM21) | (1<<WGM20) | (1<<COM21) | (0<<COM20) | (0<<CS22) | (0<<CS21) | (1<<CS20)
out TCCR2, temp
ldi temp, 0
out OCR2, temp

;sæt relæ pin til at være output, lav
sbi DDRA, PORTA0
nop
cbi PORTA, PORTA0
pop temp

.macro setspeed
ERROR: Skal kaldes med argument
.endm

.macro	setspeed_8	;tager adresse til gpr
	out OCR2, @0	;og skriver gpr til OCR2
.endm

.macro	setspeed_i	;tager konstant
	push temp
	ldi temp, @0
	out OCR2, temp
	pop temp
.endm
