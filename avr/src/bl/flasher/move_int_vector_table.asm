	;Interrupts flyttes til bootloaderen
	;(s. 68 i datablad)
.filedef temp = R16

	push temp
	ldi temp, (1<<IVCE)
	out GICR, temp
	ldi temp, (1<<IVSEL)
	out GICR, temp
	pop temp
