.include "src/bl/bl.asm"
.filedef temp = R16
.filedef temp1 = R17
.filedef temp2 = R18

.equ cur_gyr_val_addr = addr
.set addr = addr + 1

.equ map_data_start_addr = addr
.equ map_data_length = 500
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
.equ rstat_averaging = 2
.equ rstat_racing = 3

.equ gyr_rdy_addr = addr
.set addr = addr + 1

.equ map_round_addr = addr
.set addr = addr + 1

.equ map_round_set_count = 0 ; 2^X !! (0 -> 1, 1 -> 2, 2 -> 4)
.equ map_round_count = 1 << map_round_set_count

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
	.include "src/mapping/map_clearer.asm"
	.include "src/mapping/map_storer.asm"
	.include "src/mapping/send_map.asm"
	.include "src/mapping/gyr_integrate.asm"

	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]

	ldi temp1, rstat_warm_up
	sts race_status_addr, temp1
	ldi temp1, 0
	sts gyr_rdy_addr, temp1
	sts map_round_addr, temp1
main:
	lds temp1, gyr_rdy_addr
	cpi temp1, 1
	brne main
	push temp2
	pop temp2
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
	sts cur_gyr_val_addr, temp1
	ldi temp1, 0
	sts gyr_rdy_addr, temp1
	rcall got_i2c_data
	rjmp main

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"
	jmp_cmd_ne [get_code, get_map_code, send_map_cmd_end]
	rcall send_map
	send_map_cmd_end:
	reti

encoder_handler:
	rcall increment_dis
	reti

linedetector_handler:
	push temp
	lds temp, race_status_addr
	cpi temp, rstat_warm_up
	breq start_mapping
	cpi temp, rstat_mapping
	breq finished_map_round
	cpi temp, rstat_racing
	breq racing
linedetector_end:
	pop temp
	reti

start_mapping:
	rcall map_clearer
	ldi temp, rstat_mapping
	sts race_status_addr, temp
continue_mapping:
	rcall map_storer_init
	rjmp linedetector_end
finished_map_round:
	rcall map_store_done
	lds temp, map_round_addr
	inc temp
	sts map_round_addr, temp
	send_bt_byte [temp]
	send_bt_byte [map_round_count]
	cpi temp, map_round_count
	brne continue_mapping
	ldi temp, rstat_racing
	sts race_status_addr, temp
	rjmp linedetector_end
racing:
	setspeed [0]
	send_bt_bytes [1,1,1,1]
	rjmp linedetector_end

got_i2c_data:
	rcall gyr_detect_turns
	ret

gyr_drdy_isr:
	push temp1
	ldi temp1, 1
	sts gyr_rdy_addr, temp1
	pop temp1
	reti

reset_map_data_pointer:
	push temp1
	ldi temp1, low(map_data_start_addr)
	sts map_data_pointer_l, temp1
	ldi temp1, high(map_data_start_addr)
	sts map_data_pointer_h, temp1
	pop temp1
	ret
