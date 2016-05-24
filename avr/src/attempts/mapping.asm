.include "src/bl/bl.asm"
.filedef temp = R16
.filedef temp1 = R17
.filedef temp2 = R18
.filedef temp3 = R19
.filedef temp4 = R20

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

.equ map_round_set_count = 1 ; 2^X !! (0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)
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
	.include "src/mapping/map_avg.asm"
	.include "src/mapping/inner_outer.asm"
	.include "src/mapping/turn_direction_to_innerouter.asm"
	.include "src/mapping/correct_turn_lengths.asm"
	.include "src/mapping/send_map.asm"
	.include "src/mapping/gyr_integrate.asm"
	;.include "src/mapping/data_logger.asm"

	ldi temp1, rstat_warm_up
	sts race_status_addr, temp1
	ldi temp1, 0
	sts gyr_rdy_addr, temp1
	sts map_round_addr, temp1

	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
main:
	;rcall log_data_interval

	rjmp main

	delayms [10]
	phys_speed [R17, R16]
	lsr R17
	ror R16
	cpi R17, 0
	breq after_this
	ldi R16, 0xFF
after_this:
	cli
	;send_bt_byte [graph_speed_code]
	;send_bt_byte [R16]
	sei

	lds temp, cur_gyr_val_addr
	get_dis [temp3, temp2]
	cli
	send_bt_bytes [graph_gyrzhDis_code, temp3, temp2, temp]
	sei


	lds temp1, gyr_rdy_addr
	cpi temp1, 1
	breq read_i2c
	rjmp got_i2c_data
read_i2c:
	ldi temp1, 0
	sts gyr_rdy_addr, temp1
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp1]
	sts cur_gyr_val_addr, temp1
	rcall got_i2c_data
after_try_to_read_i2c:

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

	push temp3
	push temp2
	push temp1
	push temp
	in temp, SREG
	push temp

	get_time_full [temp3, temp2, temp1]
	get_dis [temp1, temp]
	send_bt_bytes [graph_next_lap_code, temp3, temp2, temp1, temp]
	rcall reset_lap_timer
	rcall reset_physs

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop temp2
	pop temp3
	reti

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
	cpi temp, map_round_count
	brne continue_mapping
	ldi temp, rstat_racing
	sts race_status_addr, temp
	setspeed [0]
	rcall average_map
	rcall	inner_outer
	rcall turn_direction_to_inner_outer
	rcall correct_turn_lengths
	;rcall start_race_lap
	rjmp linedetector_end
racing:
	;rcall start_race_lap
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
