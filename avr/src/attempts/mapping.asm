.include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2A
rjmp cmd_handler

init:
	.include "src/util/macros/cpi_jmp.asm"
	.include "src/motor/setup.asm"
	.include "src/elemag/setup.asm"
	.include "src/linedetector/setup.asm"
	.include "src/encoder/setup.asm"
	.include "src/lapt/setup.asm"
	.include "src/physs/setup.asm"
	.include "src/mapping/gyr_detect_turns.asm"

	.include "src/mapping/gyr_integrate.asm"
	.include "src/mapping/data_log_interval.asm"
	.include "src/mapping/do_data_log.asm"
	.include "src/mapping/main.asm"

	jmp main_init


encoder_handler:
	rcall increment_dis
	reti





got_i2c_data:
	rcall gyr_detect_turns
	ret

reset_map_data_pointer:
	push temp1
	ldi temp1, low(map_data_start_addr)
	sts map_data_pointer_l_addr, temp1
	ldi temp1, high(map_data_start_addr)
	sts map_data_pointer_h_addr, temp1
	pop temp1
	ret
