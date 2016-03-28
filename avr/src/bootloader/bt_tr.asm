.def store_byte = R16
.def temp1 = R17

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
  push ZL
  push ZH
  push YL
  push YH

  lds ZL, bt_tr_store_pointer_L
  lds ZH, bt_tr_store_pointer_H
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
  brne update_send_pointer

  cpi YH, high(bt_tr_buf_end + 1)
  brne update_send_pointer

  ldi YL, low(bt_tr_buf_start)
  ldi YH, high(bt_tr_buf_start)
update_send_pointer:
  sts bt_tr_send_pointer_L, YL
  sts bt_tr_send_pointer_H, YH

  ld temp1, Y
  out UDR, temp1
restore_tr_pointer_registers:
  pop YH
  pop YL
  pop ZH
  pop ZL
  ret

store_bt_to_buf:
  push ZL
  push ZH
  push YL
  push YH

  lds ZL, bt_tr_store_pointer_L
  lds ZH, bt_tr_store_pointer_H
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
  ;THROW ERROR!! (Force Send Error over bluetooth)
buffer_not_full:
  st Z, store_byte
  sbi UCSRB, UDRIE ; turn on interrupt for ready to send, if not on already. If UDR is ready, interrupt will be instantiated immidiately.

  pop YH
  pop YL
  pop ZH
  pop ZL
  ret

.undef temp1
.undef store_byte
