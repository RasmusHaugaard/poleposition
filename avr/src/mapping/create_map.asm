.filedef temp = R16

.include "src/mapping/map_clearer.asm"
.include "src/mapping/map_storer.asm"
.include "src/mapping/map_avg.asm"
.include "src/mapping/inner_outer.asm"
.include "src/mapping/turn_direction_to_innerouter.asm"
.include "src/mapping/correct_turn_lengths.asm"

.equ map_round_addr = addr
.set addr = addr + 1

.equ map_round_set_count = 0 ; 2^X !! (0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)
; 		Don't touch this ,
.equ map_round_count = 1 << map_round_set_count
; 		Don't touch this ^
rjmp create_map_file_end

start_create_map:
	push temp
	rcall map_clearer
	ldi temp, race_status_mapping
	sts race_status_addr, temp
	rcall map_storer_init
	rcall reset_gyr_integration
	pop temp
	ret

finished_map_round:
	push temp
	in temp, SREG
	push temp

	rcall map_store_done
	lds temp, map_round_addr
	inc temp
	sts map_round_addr, temp
	cpi temp, map_round_count
	breq all_map_rounds_done
	rcall map_storer_init
	rjmp finished_map_round_end
all_map_rounds_done:
	ldi temp, race_status_racing
	sts race_status_addr, temp
	rcall average_map
	rcall	inner_outer
	rcall turn_direction_to_inner_outer
	rcall correct_turn_lengths
	send_bt_byte [87]
	disable_control_speed
	brake [0]
finished_map_round_end:
	pop temp
	out SREG, temp
	pop temp
	ret

create_map_file_end:
