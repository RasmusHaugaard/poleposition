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

	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp]

main:
	rcall log_data_interval
	rcall gyr_reader



	rjmp main

main_file_end:
