.macro force_receive_bt_byte
force_receive_%:
	sbis UCSRA, RXC
	rjmp force_receive_%
.endm

.macro force_receive_bt_byte_8
	force_receive_bt_byte
	in @0, UDR
.endm
