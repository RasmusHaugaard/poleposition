.include "src/def/m32def.inc"
.filedef temp = R16
.filedef cnt1 = R17
.filedef cnt2 = R18
.filedef cnt3 = R19

.equ char = 20

.org 0x00
	rjmp init

.org 0x2a
init:
	.include "src/util/setup/stack_pointer.asm"
	.include "src/bt/setup.asm"
	.include "src/bt/macros/rc_force.asm"
	.include "src/bt/macros/tr_force.asm"

main:
	force_receive_bt_byte [cnt3]
loop3:
	rcall sendkb
	dec cnt3
	brne loop3
	rjmp main

sendkb:
	ldi cnt1, 10
loop1:
	ldi cnt2, 100
loop2:
	force_send_bt_byte [char]
	dec cnt2
	brne loop2
	dec cnt1
	brne loop1
	ret
