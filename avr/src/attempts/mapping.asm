.include "src/bl/bl.asm"
.filedef temp1 = R17
.filedef temp2 = R18

.equ cur_gyr_val_addr = addr
.set addr = addr + 1

.equ map_data_start_addr = addr
.equ map_data_length = 200
.set addr = addr + map_data_length

.equ straight_segment = 255
.equ left_segment = 251
.equ right_segment = 253

.equ map_data_pointer_l = addr
.set addr = addr + 1
.equ map_data_pointer_h = addr
.set addr = addr + 1

.equ race_status_addr = addr
.set addr = addr + 1

.equ rstat_warm_up = 0
.equ rstat_mapping = 1
.equ rstat_racing = 2

.org 0x00
rjmp init

.org 0x2A
rjmp cmd_handler

init:
	.include "src/util/macros/cpi_jmp.asm"
	.include "src/motor/setup.asm"
	.include "src/elemag/setup.asm"
	.include "src/i2c/setup.asm"
	.include "src/i2c/gyr/setup.asm"
	.include "src/i2c/gyr/setup_drdy_int.asm"
	.include "src/linedetector/setup.asm"
	.include "src/encoder/setup.asm"
	.include "src/lapt/setup.asm"
	.include "src/physs/setup.asm"
	.include "src/mapping/gyr_detect_turns.asm"
	.include "src/mapping/map_storer.asm"
	.include "src/mapping/send_map.asm"

	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]

	ldi temp1, rstat_warm_up
	sts race_status_addr, temp1
main:
	rjmp main

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"
	reti

encoder_handler:
	rcall increment_dis
	reti

linedetector_handler:
	lds temp1, race_status_addr
	cpi temp1, rstat_warm_up
	breq start_mapping
	cpi temp1, rstat_mapping
	breq stop_mapping
	cpi temp1, rstat_racing
	breq racing
linedetector_end:
	rcall reset_map_data_pointer
	rcall reset_lap_timer
	rcall reset_physs_dis
	reti
start_mapping:
	ldi temp1, rstat_mapping
	sts race_status_addr, temp1
	rcall map_storer_init
	rjmp linedetector_end
stop_mapping:
	rcall map_store_done
	ldi temp1, rstat_racing
	sts race_status_addr, temp1
	setspeed [0]
	rcall send_map
	rjmp linedetector_end
racing:
	rjmp linedetector_end

got_i2c_data:
	rcall gyr_detect_turns
	ret

gyr_drdy_isr:
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp2]
	sts cur_gyr_val_addr, temp2
	rcall got_i2c_data
	reti

reset_map_data_pointer:
	push temp1
	ldi temp1, low(map_data_start_addr)
	sts map_data_pointer_l, temp1
	ldi temp1, high(map_data_start_addr)
	sts map_data_pointer_h, temp1
	pop temp1
	ret
