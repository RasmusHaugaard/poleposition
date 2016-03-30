.equ tr_preserve_z = 1
.equ tr_preserve_y = 1

.filedef store_byte = R16
.filedef temp1 = R17

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

.macro force_send_bt_byte
sendchar_%:
	sbis UCSRA, UDRE
	rjmp sendchar_%
	out UDR, store_byte
	sei
.endm

.macro force_send_bt_byte_i
	cli
	ldi store_byte, @0
	force_send_bt_byte
.endm

.macro force_send_bt_byte_8
	cli
	mov store_byte, @0
	force_send_bt_byte
.endm

bt_tr_start:
	rcall init_bt_tr_pointers
	rjmp bt_tr_end

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
  brne update_send_pointer

  cpi YH, high(bt_tr_buf_end + 1)
  brne update_send_pointer

  ldi YL, low(bt_tr_buf_start)
  ldi YH, high(bt_tr_buf_start)
update_send_pointer:
.if tr_preserve_y = 1
  sts bt_tr_send_pointer_L, YL
  sts bt_tr_send_pointer_H, YH
.endif
tr_transmit:
  ld temp1, Y
  out UDR, temp1
restore_tr_pointer_registers:
.if tr_preserve_y = 1
	pop YH
  pop YL
.endif
.if tr_preserve_z = 1
  pop ZH
  pop ZL
.endif
  ret

store_bt_to_buf:
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
  ;THROW ERROR!! (Force Send Error over bluetooth)
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
  ret

bt_tr_end:
