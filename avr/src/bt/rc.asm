.filedef input = R16
.filedef temp1 = R17

.equ bt_rc_buf_start = addr
.equ bt_rc_buf_length = 10  ; byte buffer til indkommende kommandoer
	.set addr = addr + bt_rc_buf_length - 1
.equ bt_rc_buf_end = addr
	.set addr = addr + 1
.equ bt_rc_pointer_L = addr
	.set addr = addr + 1
.equ bt_rc_pointer_H = addr
	.set addr = addr + 1
.equ bt_rc_status = addr ; receive data status
	.set addr = addr + 1

.equ set_length = 3
.equ get_length = 3

.set saved_pc = PC
.org 0x1a
	jmp bl_rxcie_handler
.org saved_pc

.include "src/bt/macros/jmp_cmd_ne.asm"

bt_rc_start:
	ldi temp1, 0
	sts bt_rc_status, temp1
	rcall reset_bt_rc_pointer
	rjmp bt_rc_end

bl_error_rxcie:
	force_send_bt_byte [bl_first_page_empty]
	jmp bl_reprogram

bl_rxcie_handler:
	push input
	push temp1
	lds temp1, SREG
	push temp1
	push ZL
	push ZH

	sbis UCSRA, RXC ; make sure, we don't end in the handler without interrupt
	rjmp bl_error_rxcie

	in input, UDR
	lds temp1, bt_rc_status
	cpi temp1, 0
	brne expecting_other_than_first_byte

	cpi input, var_code
	breq received_var_code

	cpi input, set_code
	breq received_set_code

	cpi input, get_code
	breq received_get_code

	cpi input, ping_code
	breq received_ping_code

	cpi input, reprogram_code
	breq received_reprogram_code

	rjmp error_undefined_rc_code
rxcie_end:
	pop ZH
	pop ZL
	pop temp1
	out SREG, temp1
	pop temp1
	pop input
	reti

received_var_code:
	ldi temp1, var_code
	sts bt_rc_status, temp1
	rjmp rxcie_end
received_set_code:
	rcall store_input_in_rc_buffer
	ldi temp1, set_length - 1
	sts bt_rc_status, temp1
	rjmp rxcie_end
received_get_code:
	rcall store_input_in_rc_buffer
	ldi temp1, get_length - 1
	sts bt_rc_status, temp1
	rjmp rxcie_end
received_ping_code:
	send_bt_byte [ping_code]
	rjmp rxcie_end
received_reprogram_code:
	jmp bl_reprogram
error_undefined_rc_code:
	send_bt_byte [bl_rc_unknown_set_code]
	rjmp rxcie_end

expecting_other_than_first_byte:
	cpi temp1, var_code
	brne expecting_data
	sts bt_rc_status, input ; received the length of the variable command - future bytes will be stored in receive buffer
	rjmp rxcie_end
expecting_data:
	rcall store_input_in_rc_buffer
	dec temp1
	sts bt_rc_status, temp1
	brne rxcie_end
	rcall reset_bt_rc_pointer
	pop ZH
	pop ZL
	pop temp1
	out SREG, temp1
	pop temp1
	pop input
	jmp 0x2A

store_input_in_rc_buffer:
	lds ZL, bt_rc_pointer_L
	lds ZH, bt_rc_pointer_H
	st Z+, input
	sts bt_rc_pointer_L, ZL
	sts bt_rc_pointer_H, ZH
	ret

reset_bt_rc_pointer:
	ldi ZL, low(bt_rc_buf_start)
	ldi ZH, high(bt_rc_buf_start)
	sts bt_rc_pointer_L, ZL
	sts bt_rc_pointer_H, ZH
	ret

bt_rc_end:
