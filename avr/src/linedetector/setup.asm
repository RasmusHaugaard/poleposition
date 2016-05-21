.filedef temp = R16

.set saved_pc = PC
.org 0x04
	jmp linedetector_handler
.org saved_pc

push temp
in temp, SREG
push temp

cli
in temp, GICR
ori temp, 1<<INT1	;Port D, pin 3
out GICR, temp
in temp, MCUCR
ori temp, (1<<ISC10) | (1<<ISC11)	;trigger ved puls stigning
out	MCUCR, temp

pop temp
out SREG, temp
pop temp
