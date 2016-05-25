.filedef store_byte = R16
.filedef temp = R17

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

.equ saved_sreg_addr = addr
	.set addr = addr + 1

.set saved_pc = PC
.org 0x1C
  jmp bl_udrei_handler
.org saved_pc

.macro send_bt_byte
	.error "skal kaldes med argument"
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
	sts bt_tr_store_pointer_L, ZL
	sts bt_tr_store_pointer_H, ZH
	sts bt_tr_send_pointer_L, YL
	sts bt_tr_send_pointer_H, YH
	ret

bl_udrei_handler:
	rcall check_send_bt_from_buf
	reti

check_send_bt_from_buf:
	;This will only be called inside an interrupt and interrupts are therefore already disabled
	;Since it is called inside an interrupt, it is very important, that no gps, nor the SREG is affected
	push temp
	in temp, SREG
	push ZL
	push ZH
	lds ZL, bt_tr_store_pointer_L
	lds ZH, bt_tr_store_pointer_H
	push YL
	push YH
	lds YL, bt_tr_send_pointer_L
	lds YH, bt_tr_send_pointer_H
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
	push temp
	ld temp, Y
	out UDR, temp
	pop temp
	sts bt_tr_send_pointer_L, YL
	sts bt_tr_send_pointer_H, YH
restore_tr_pointer_registers:
	pop YH
	pop YL
	pop ZH
	pop ZL
	out SREG, temp
	pop temp
	ret

store_bt_to_buf:
	push temp
	in temp, SREG
	cli
	push ZL
	push ZH
	lds ZL, bt_tr_store_pointer_L
	lds ZH, bt_tr_store_pointer_H
	push YL
	push YH
	lds YL, bt_tr_send_pointer_L
	lds YH, bt_tr_send_pointer_H
	adiw ZH:ZL, 1

	cpi ZL, low(bt_tr_buf_end + 1)
	brne update_store_pointer
	cpi ZH, high(bt_tr_buf_end + 1)
	brne update_store_pointer

	ldi ZL, low(bt_tr_buf_start)
	ldi ZH, high(bt_tr_buf_start)
update_store_pointer:
	sts bt_tr_store_pointer_L, ZL
	sts bt_tr_store_pointer_H, ZH
	cp ZL, YL
	brne buffer_not_full
	cp ZH, YH
	brne buffer_not_full
	;TODO: Meld fejl ved overflow!
buffer_not_full:
	st Z, store_byte
	sbi UCSRB, UDRIE ; turn on interrupt for ready to send, if not on already. If UDR is ready, interrupt will be instantiated immidiately.
	pop YH
	pop YL
	pop ZH
	pop ZL
	out SREG, temp
	pop temp
	ret

bt_tr_end:

.macro send_bt_bytes
	.error "skal kaldes med argumenter"
.endm

.macro send_bt_bytes_i
	send_bt_byte [@0]
.endm

.macro send_bt_bytes_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	send_bt_byte [@6]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	send_bt_byte [@6]
	send_bt_byte [@7]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	send_bt_byte [@6]
	send_bt_byte [@7]
	send_bt_byte [@8]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_i_i_i_i_i_i_i_i_i
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	send_bt_byte [@6]
	send_bt_byte [@7]
	send_bt_byte [@8]
	send_bt_byte [@9]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8_8_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8_8_8_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8_8_8_8_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm

.macro send_bt_bytes_i_8_8_8_8_8_8
	push temp
	in temp, SREG
	cli
	sts saved_sreg_addr, temp
	pop temp
	send_bt_byte [@0]
	send_bt_byte [@1]
	send_bt_byte [@2]
	send_bt_byte [@3]
	send_bt_byte [@4]
	send_bt_byte [@5]
	send_bt_byte [@6]
	push temp
	lds temp, saved_sreg_addr
	out SREG, temp
	pop temp
.endm
