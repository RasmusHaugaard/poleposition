.include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2a
init:


main:
  send_bt_byte [200]
  delays [2]
  rjmp main
