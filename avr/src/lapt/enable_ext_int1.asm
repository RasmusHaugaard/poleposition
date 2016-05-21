.filedef temp = R16

.set saved_pc = PC
.org 0x04
	rjmp EXT_INT1
.org saved_pc

push temp
in temp, SREG
push temp

cli
in temp, GICR
andi temp, 1<<INT1	;tilader interrupt ved externt trigger 1 (Port D, pin 3)
out GICR, temp
in temp, MCUCR
andi temp, (1<<ISC10) | (1<<ISC11)	;ops�tter til at trigge ved puls stigning
out	MCUCR, temp

pop temp
out SREG, temp
pop temp
