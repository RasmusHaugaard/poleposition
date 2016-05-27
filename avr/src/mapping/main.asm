.filedef temp = R16

.equ race_status_addr = addr
.set addr = addr + 1

.equ race_status_warm_up = 0
.equ race_status_mapping = 1
.equ race_status_racing = 2

jmp main_file_end

main_init:
	ldi temp, race_status_warm_up
	sts race_status_addr, temp
	ldi temp, 0
	sts map_round_addr, temp

main:
	call control_speed
	rcall gyr_reader
	rcall log_data_interval

	lds temp, race_status_addr
	cpi temp, race_status_racing
	brne not_racing
	rcall race_main
not_racing:

	rjmp main

main_file_end:
