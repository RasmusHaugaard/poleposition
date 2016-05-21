.filedef temp = R16

.set saved_pc = PC
.org 0x02
	rjmp EXT_INT0
.org saved_pc

push temp
in temp, SREG
push temp

cli
in temp, GICR
andi temp, 1<<INT0	;tilader interrupt ved externt trigger 0 (Port D, pin 2)
out GICR, temp
in temp, MCUCR
andi temp, (1<<ISC00) | (1<<ISC01)	;ops�tter til at trigge ved puls stigning
out	MCUCR, temp

pop temp
out SREG, temp
pop temp
