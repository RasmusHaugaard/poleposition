.filedef temp = R16

push temp
in temp, SREG
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
out SREG, temp
pop temp

.macro setspeed
	.error "Skal kaldes med argument"
.endm

.macro	setspeed_8	;tager adresse til gpr
	cbi PORTA, PORTA0
	out OCR2, @0	;og skriver gpr til OCR2
.endm

.macro	setspeed_i	;tager konstant
	cbi PORTA, PORTA0
	push temp
	ldi temp, @0
	out OCR2, temp
	pop temp
.endm

.macro brake
 .error "Skal kaldes med argument"
.endm

.macro brake_i
	sbi PORTA, PORTA0
	out OCR2, @0
.endm

.macro	setspeed_i
	sbi PORTA, PORTA0
	push temp
	ldi temp, @0
	out OCR2, temp
	pop temp
.endm
