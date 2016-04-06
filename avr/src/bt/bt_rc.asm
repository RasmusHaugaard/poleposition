.filedef input = R16
.filedef temp1 = R17

.equ set_code = 85
.equ set_length = 3

.equ ping_code = 86
.equ var_code = 255
.equ reprogram_code = 87

.equ error_code_bl_undefined_rc_code = 100

.include "src/bt/bt_rc_force.asm"

bt_rc_start:
	ldi temp1, 0
	sts bt_rc_status, temp1
	rcall reset_bt_rc_pointer
	rjmp bt_rc_end

bl_rxcie_handler:
	push input
  push temp1
  push ZL
  push ZH
	in input, UDR
  lds temp1, bt_rc_status
  cpi temp1, 0
  brne expecting_other_than_first_byte
  cpi input, var_code
  breq received_var_code
  cpi input, set_code
  breq received_set_code
  cpi input, ping_code
  breq received_ping_code
  cpi input, reprogram_code
  breq received_reprogram_code
  rjmp error_undefined_rc_code
rxcie_end:
  pop ZH
  pop ZL
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
received_ping_code:
  ;ldi temp1, ping_code
  ;send_bt_byte [temp1]
	send_bt_byte [ping_code]
	rjmp rxcie_end
received_reprogram_code:
  rjmp rxcie_end
error_undefined_rc_code:
  ldi temp1, error_code_bl_undefined_rc_code
  send_bt_byte [temp1]
  rjmp rxcie_end

expecting_other_than_first_byte:
  cpi temp1, var_code
  brne expecting_data
  sts bt_rc_status, input
  rjmp rxcie_end
expecting_data:
  rcall store_input_in_rc_buffer
  dec temp1
	sts bt_rc_status, temp1
  brne rxcie_end
  rcall reset_bt_rc_pointer
  call app_command_handler
  rjmp rxcie_end

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
