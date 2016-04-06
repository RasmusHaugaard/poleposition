.filedef store_byte = R16
.filedef temp1 = R17

.macro force_send_bt_byte
sendchar_%:
	sbis UCSRA, UDRE
	rjmp sendchar_%
	out UDR, store_byte
	out SREG, temp1
	pop temp1
	pop store_byte
.endm

.macro force_send_bt_byte_i
	push store_byte
	push temp1
	in temp1, SREG
	ldi store_byte, @0
	force_send_bt_byte
.endm

.macro force_send_bt_byte_8
	push store_byte
	push temp1
	in temp1, SREG
	mov store_byte, @0
	force_send_bt_byte
.endm
