.include "src/m32def.inc"
.equ folc = 16000000 ; 16MHz
.org 0	; lokation til reset interrupt
	rjmp setup

.org 0x2a ;efter interreupts
	.include "src/macros/end.asm"
	.include "src/macros/motor_pwm.asm"
	.include "src/macros/soft_reset.asm"
setup:
	.include "src/setup/stack_pointer.asm"
	.include "src/setup/bluetooth.asm"
	.include "src/setup/motor_pwm.asm"
	rjmp init
init:
	setspeed [0]
	ldi R16, 0
	rjmp mainloop

mainloop:
	inc R16
	ldi R17, 0
incr:
	inc R17
	brne incr	
	setspeed [R16]
	rjmp mainloop