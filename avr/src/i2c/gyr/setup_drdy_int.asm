.filedef temp = R16

.set saved_pc = PC
.org 0x02
	jmp gyr_drdy_isr
.org saved_pc

push temp
in temp, SREG
push temp

cli
in temp, GICR
ori temp, 1<<INT0	;Port D, pin 2
out GICR, temp
in temp, MCUCR
ori temp, (1<<ISC00) | (1<<ISC01)	;trigger ved puls stigning
out	MCUCR, temp

pop temp
out SREG, temp
pop temp
