.include "src/def/m32def.inc"
.filedef temp1 = R16

.org LARGEBOOTSTART ; vores atmega er fuset til at starte i bootloaderen.
	jmp 0x00

.org 0x00
	rjmp init

.org 0x2a ;program efter interrupt table
init:
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_setup.asm"
	.include "src/bt/bt_tr_force.asm"
	.include "src/bt/bt_rc_force.asm"
	.include "src/util/branching.asm"
	rjmp main

main:
	force_receive_bt_byte [temp1]
	force_send_bt_byte [temp1]
	rjmp main
