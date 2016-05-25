.filedef temp = R16

.equ stop_distance = 100

rjmp race_file_end

finished_race_lap:
	rcall start_race_lap
	ret

start_race_lap:
	rcall reset_map_data_pointer

	ret


race_main:

	ret

race_file_end:
