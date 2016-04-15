.filedef store_byte = R16
.filedef temp1 = R17
.filedef tempm = R18

.equ bl_rc_buf_store_pointer_L = 0x60
.equ bl_rc_buf_store_pointer_H = 0x61
.equ bl_rc_buf_load_pointer_L = 0x62
.equ bl_rc_buf_load_pointer_H = 0x63

.equ bl_rc_buf_start_addr = 0x64
.equ bl_rc_buf_end_addr = RAMEND - 200 ;Masser af plads, men gør plads til stack pointeren..
; NB: Der kan reelt kun være bufferSize - 1 i bufferen pga. den måde, der tjekkes, om der er ny data i bufferen.

bl_rc_buf_start:
	rcall init_bl_rc_buf_pointers
	jmp bl_rc_buf_end

init_bl_rc_buf_pointers:
  ldi ZL, low(bl_rc_buf_start_addr)
  ldi ZH, high(bl_rc_buf_start_addr)
  mov YL, ZL
  mov YH, ZH
  sts bl_rc_buf_store_pointer_L, ZL
  sts bl_rc_buf_store_pointer_H, ZH
  sts bl_rc_buf_load_pointer_L, YL
  sts bl_rc_buf_load_pointer_H, YH
  ret

.macro pf_load_from_buffer
.endm

.macro pf_load_from_buffer_8
	push store_byte
	rcall check_load_byte_from_buf
	mov @0, store_byte
	pop store_byte
.endm

check_load_byte_from_buf:
  push ZL
  push ZH
	push YL
  push YH
check_load_byte_from_buf_loop:
	cli ; Data integritet - måske ikke nødvendigt.
	lds ZL, bl_rc_buf_store_pointer_L
	lds ZH, bl_rc_buf_store_pointer_H
  lds YL, bl_rc_buf_load_pointer_L
  lds YH, bl_rc_buf_load_pointer_H
	sei
  cp ZL, YL ; Hvis ikke vores load pointer peger det samme sted hen, som vores store pointer, vil der være modtaget ny data.
  brne load_byte_from_buf
  cp ZH, YH
  brne load_byte_from_buf
  rjmp check_load_byte_from_buf_loop

load_byte_from_buf:
  adiw YH:YL, 1
	;Tjek for, om Y nu peger på den byte lige til højre for den sidste byte i vores buffer.
	;Hvis den gør det, skal Y pege på den første byte i bufferen i stedet.
  cpi YL, low(bl_rc_buf_end_addr + 1)
  brne update_load_pointer
  cpi YH, high(bl_rc_buf_end_addr + 1)
  brne update_load_pointer

  ldi YL, low(bl_rc_buf_start_addr)
  ldi YH, high(bl_rc_buf_start_addr)
update_load_pointer:
  sts bl_rc_buf_load_pointer_L, YL
  sts bl_rc_buf_load_pointer_H, YH

  ld store_byte, Y
restore_load_pointer_registers:
	pop YH
  pop YL
  pop ZH
  pop ZL
  ret

pf_bl_rxcie_handler:
	push store_byte
	in store_byte, UDR
  rcall pf_bl_store_byte_to_buf
	pop store_byte
  reti

pf_bl_store_byte_to_buf:
	push temp1
	in temp1, SREG
  push ZL
  push ZH
	push YL
	push YH
	lds ZL, bl_rc_buf_store_pointer_L
  lds ZH, bl_rc_buf_store_pointer_H
	lds YL, bl_rc_buf_load_pointer_L
	lds YH, bl_rc_buf_load_pointer_H

  adiw ZH:ZL, 1

  cpi ZL, low(bl_rc_buf_end_addr + 1)
  brne pf_update_store_pointer

  cpi ZH, high(bl_rc_buf_end_addr + 1)
  brne pf_update_store_pointer

  ldi ZL, low(bl_rc_buf_start_addr)
  ldi ZH, high(bl_rc_buf_start_addr)
pf_update_store_pointer:
  sts bl_rc_buf_store_pointer_L, ZL
  sts bl_rc_buf_store_pointer_H, ZH
  cp ZL, YL
  brne pf_buffer_not_full
  cp ZH, YH
  brne pf_buffer_not_full
	force_send_bt_byte [pf_tr_buffer_overflow_error]
pf_buffer_not_full:
  st Z, store_byte
  pop YH
  pop YL
  pop ZH
  pop ZL
	out SREG, temp1
	pop temp1
  ret

bl_rc_buf_end:
