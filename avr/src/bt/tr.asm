.filedef store_byte = R16
.filedef temp1 = R17
.filedef tempm = R18

.equ tr_preserve_z = 1
.equ tr_preserve_y = 1

.equ bt_tr_buf_start = addr
.equ bt_tr_buf_length = 100
  .set addr = addr + bt_tr_buf_length - 1
.equ bt_tr_buf_end = addr
	.set addr = addr + 1
.equ bt_tr_store_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_store_pointer_H = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_H = addr
  .set addr = addr + 1

.set saved_pc = PC
.org 0x1C
  jmp bl_udrei_handler
.org saved_pc

.macro send_bt_byte
	call store_bt_to_buf
.endm

.macro send_bt_byte_8
	push store_byte
	mov store_byte, @0
	call store_bt_to_buf
	pop store_byte
.endm

.macro send_bt_byte_i
	push store_byte
	ldi store_byte, @0
	call store_bt_to_buf
	pop store_byte
.endm

bt_tr_start:
	rcall init_bt_tr_pointers
	jmp bt_tr_end

init_bt_tr_pointers:
	ldi ZL, low(bt_tr_buf_start)
	ldi ZH, high(bt_tr_buf_start)
	mov YL, ZL
	mov YH, ZH
.if tr_preserve_z = 1
	sts bt_tr_store_pointer_L, ZL
	sts bt_tr_store_pointer_H, ZH
.endif
.if tr_preserve_y = 1
	sts bt_tr_send_pointer_L, YL
	sts bt_tr_send_pointer_H, YH
.endif
	ret

bl_udrei_handler:
	rcall check_send_bt_from_buf
	reti

check_send_bt_from_buf:
	;This will only be called inside an interrupt and interrupts are therefore already disabled
	;Since it is called inside an interrupt, it is very important, that no gps, nor the SREG is affected
	push temp1
	in temp1, SREG
.if tr_preserve_z = 1
	push ZL
	push ZH
	lds ZL, bt_tr_store_pointer_L
	lds ZH, bt_tr_store_pointer_H
.endif
.if tr_preserve_y = 1
	push YL
	push YH
	lds YL, bt_tr_send_pointer_L
	lds YH, bt_tr_send_pointer_H
.endif
	cp ZL, YL ; Hvis ikke vores send pointer peger det samme sted hen, som vores store pointer, vil der være data, der skal sendes.
	brne send_bt_from_buf
	cp ZH, YH
	brne send_bt_from_buf

	cbi UCSRB, UDRIE ; turn off interrupt for ready to send and return, if buffer is empty.
	rjmp restore_tr_pointer_registers
send_bt_from_buf:
	adiw YH:YL, 1

	cpi YL, low(bt_tr_buf_end + 1)
	brne tr_transmit
	cpi YH, high(bt_tr_buf_end + 1)
	brne tr_transmit

	ldi YL, low(bt_tr_buf_start)
	ldi YH, high(bt_tr_buf_start)
tr_transmit:
	push temp1
	ld temp1, Y
	out UDR, temp1
	pop temp1
.if tr_preserve_y = 1
	sts bt_tr_send_pointer_L, YL
	sts bt_tr_send_pointer_H, YH
.endif
restore_tr_pointer_registers:
.if tr_preserve_y = 1
	pop YH
	pop YL
.endif
.if tr_preserve_z = 1
	pop ZH
	pop ZL
.endif
	out SREG, temp1
	pop temp1
	ret

store_bt_to_buf:
	push temp1
	in temp1, SREG
	cli
.if tr_preserve_z = 1
	push ZL
	push ZH
	lds ZL, bt_tr_store_pointer_L
	lds ZH, bt_tr_store_pointer_H
.endif
.if tr_preserve_y = 1
	push YL
	push YH
	lds YL, bt_tr_send_pointer_L
	lds YH, bt_tr_send_pointer_H
.endif
	adiw ZH:ZL, 1

	cpi ZL, low(bt_tr_buf_end + 1)
	brne update_store_pointer
	cpi ZH, high(bt_tr_buf_end + 1)
	brne update_store_pointer

	ldi ZL, low(bt_tr_buf_start)
	ldi ZH, high(bt_tr_buf_start)
update_store_pointer:
.if tr_preserve_z = 1
	sts bt_tr_store_pointer_L, ZL
	sts bt_tr_store_pointer_H, ZH
.endif
	cp ZL, YL
	brne buffer_not_full
	cp ZH, YH
	brne buffer_not_full
	;TODO: Meld fejl ved overflow!
buffer_not_full:
	st Z, store_byte
	sbi UCSRB, UDRIE ; turn on interrupt for ready to send, if not on already. If UDR is ready, interrupt will be instantiated immidiately.
.if tr_preserve_y = 1
	pop YH
	pop YL
.endif
.if tr_preserve_z = 1
	pop ZH
	pop ZL
.endif
	out SREG, temp1
	pop temp1
	ret

bt_tr_end:
