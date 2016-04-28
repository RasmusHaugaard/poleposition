.filedef temp1 = R16

.macro force_receive_bt_byte
	push temp1
fr_%:
	sbis UCSRA, RXC
	rjmp fr_%
	in temp1, UDR
	pop temp1
.endm

.macro force_receive_bt_byte_8
fr_8_%:
	sbis UCSRA, RXC
	rjmp fr_8_%
	in @0, UDR
.endm
