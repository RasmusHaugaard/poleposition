.include "src/m32def.inc"
.equ RAMSTART = 0x60
.def temp = R16
.def temp1 = R17

.org 0x00
  rjmp init
.org 0x1a
  rjmp rxciehandler ; USART RX Complete Handler
.org 0x1c
  rjmp udreihandler ; UDR Empty handler
.org 0x2a
init:
  .include "src/setup/bluetooth.asm"
  .include "src/setup/stack_pointer.asm"

  rcall resetpointers
  sbi UCSRB, RXCIE  ; enable uart receive complete interrupt
  sei ; set global interrupt flag
  rjmp main

main:
  rjmp main

resetpointers:
  ldi ZL, low(RAMSTART)
  ldi ZH, high(RAMSTART)
  mov YL, ZL
  mov YH, ZH
  ret

rxciehandler:
  in temp, UDR
  cpi temp, 0
  brne store
  rcall triggersend
  reti
store:
  st Z+, temp
  reti

udreihandler:
  rcall send
  reti

triggersend:
  sbi UCSRB, UDRIE ; turn on interrupt for ready to send, if not on already
  sbis UCSRA, UDRE ; if ready to send, send immidiately
  rcall send
  ret

send:
  mov temp, ZL
  mov temp1, ZH
  sub temp, YL
  sbc temp1, YH
  brne send1
  rcall resetpointers
  cbi UCSRB, UDRIE ; turn off interrupt for ready to send.
  ret
send1:
  ld temp, Y+
  out UDR, temp
  ret
