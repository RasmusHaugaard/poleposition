.filedef temp = R16

.set saved_pc = PC
.org 0x06
	rjmp encoder_handler
.org saved_pc

push temp
in temp, SREG
push temp

cli
cbi DDRB, PB2
nop
sbi PORTB, PB2
in temp, GICR
ori temp, 1<<INT2	;tilader interrupt ved externt trigger 2 (Port B, pin 2)
out GICR, temp
in temp, MCUCR
ori temp, 1<<ISC2 ;opsættes til at trigge ved puls stigning
out MCUCSR, temp

pop temp
out SREG, temp
pop temp
