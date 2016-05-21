.include "src/def/m32def.inc"
.filedef temp = R16

.org 0x00
rjmp init

.org 0x2A
init:
	.include "src/bt/setup.asm"
	.include "src/bt/macros/rc_force.asm"
	.include "src/bt/macros/tr_force.asm"

main:
	force_receive_bt_byte [temp]
	force_send_bt_byte [temp]
	rjmp main
