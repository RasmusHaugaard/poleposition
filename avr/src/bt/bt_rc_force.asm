.filedef temp1 = R16

.macro force_receive_bt_byte
	push temp1
	in temp1, SREG
	cli
fr_%:
	sbis UCSRA, RXC
	rjmp fr_%
	push temp1
	in temp1, UDR
	pop temp1
	out SREG, temp1
	pop temp1
.endm

.macro force_receive_bt_byte_8
	push temp1
	in temp1, SREG
	cli
fr_8_%:
	sbis UCSRA, RXC
	rjmp fr_8_%
	in @0, UDR ;TODO: Hvis denne er R16, er der troubles
	out SREG, temp1
	pop temp1
.endm
