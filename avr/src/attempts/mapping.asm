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
	.include "src/mapping/map_clearer.asm"
	.include "src/mapping/map_storer.asm"
	.include "src/mapping/map_avg.asm"
	.include "src/mapping/inner_outer.asm"
	.include "src/mapping/turn_direction_to_innerouter.asm"
	.include "src/mapping/correct_turn_lengths.asm"
	.include "src/mapping/gyr_integrate.asm"
	.include "src/mapping/data_log_interval.asm"
	.include "src/mapping/do_data_log.asm"
	.include "src/mapping/main.asm"

	jmp main_init


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

reset_map_data_pointer:
	push temp1
	ldi temp1, low(map_data_start_addr)
	sts map_data_pointer_l_addr, temp1
	ldi temp1, high(map_data_start_addr)
	sts map_data_pointer_h_addr, temp1
	pop temp1
	ret
