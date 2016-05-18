 .include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2A
init:


main:

  rjmp main
