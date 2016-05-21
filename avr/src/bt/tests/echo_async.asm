.include "src/def/m32def.inc"
.filedef temp = R16

.org 0x00
rjmp init

.org 0x2A
init:
	.include "src/bt/bt.asm"

main:
	force_receive_bt_byte [temp]
	force_send_bt_byte [temp]
	rjmp main
