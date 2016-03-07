	rjmp init

init:
	;setup
		.include "src/setup/stack_pointer.asm"
		.include "src/setup/bluetooth.asm"
		.include "src/setup/motor_pwm.asm"
	;setup macros
		.include "src/macros/motor_pwm.asm"
	rjmp mainloop

mainloop:
	setspeed [R16,8]
	rjmp mainloop