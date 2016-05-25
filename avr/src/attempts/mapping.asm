.include "src/bl/bl.asm"

.filedef temp = R16

.org 0x00
rjmp init

.org 0x2D
init:
	.include "src/util/macros/cpi_jmp.asm"
	.include "src/motor/setup.asm"
	.include "src/elemag/setup.asm"

	.include "src/linedetector/setup.asm"
	.include "src/encoder/setup.asm"

	.include "src/lapt/setup.asm"
	.include "src/physs/setup.asm"
	.include "src/mapping/speed_controller.asm"

	.include "src/mapping/linedetector_handler.asm"
	.include "src/mapping/encoder_handler.asm"
	.include "src/mapping/gyr_reader.asm"
	.include "src/mapping/gyr_detect_turns.asm"
	.include "src/mapping/gyr_integrate.asm"

	.include "src/mapping/create_map.asm"
	.include "src/mapping/race.asm"

	.include "src/mapping/data_log_interval.asm"

	.include "src/mapping/cmd_handler.asm"
	.include "src/mapping/main.asm"
	jmp main_init
