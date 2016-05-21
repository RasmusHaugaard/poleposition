;PWM opsætning.  (s. 561)
;Vores Elektromagnets PWM er sat på PB3, så vi bruger Timer0 til PWM og TCCR0 registeret
;Den sammenligner timer0(TCNT0) og OCR0.
;Vi kan så styre dutycycle med OCR0.
;Eks. out OCR2, 255/4 for 25% dutycycle
.filedef temp = R16

push temp
in temp, SREG
push temp

ldi temp, DDRB
ori temp, (1<<PB3)
out DDRB, temp
		;PWM - Phase Correct------------  clear on match ------  pwm clock
ldi temp, (0<<WGM01) | (1<<WGM00) | (1<<COM01) | (0<<COM00) | (0<<CS02) | (0<<CS01) | (1<<CS00)
out TCCR0, temp
ldi temp, 0
out OCR0, temp

pop temp
out SREG, temp
pop temp

.macro setelemag
	.error "Skal kaldes med argument"
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
