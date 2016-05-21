.include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2A
rjmp app_command_int_handler

init:
	;.include "src/lapt/lapt.asm"
	;.include "src/physs/physical_speed.asm"
	.include "src/motor/motor_pwm.asm"
	.include "src/elemag/elemag_pwm.asm"

main:
	rjmp main

app_command_int_handler:
	.include "src/motor/motor_bt_app_command.asm"
	.include "src/elemag/elemag_bt_app_command.asm"
	reti
