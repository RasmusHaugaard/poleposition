.filedef store_byte = R16
.filedef temp1 = R17

.macro force_send_bt_byte
sendchar_%:
	sbis UCSRA, UDRE
	rjmp sendchar_%
	out UDR, store_byte
.endm

.macro force_send_bt_byte_i
	push store_byte
	push temp1
	ldi store_byte, @0
	in temp1, SREG
sendchar_i_%:
	sbis UCSRA, UDRE
	rjmp sendchar_i_%
	out UDR, store_byte
	out SREG, temp1
	pop temp1
	pop store_byte
.endm

.macro force_send_bt_byte_8
	push store_byte
	push temp1
	mov store_byte, @0
	in temp1, SREG
sendchar_8_%:
	sbis UCSRA, UDRE
	rjmp sendchar_8_%
	out UDR, store_byte
	out SREG, temp1
	pop temp1
	pop store_byte
.endm
