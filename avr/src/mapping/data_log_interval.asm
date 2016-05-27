.filedef curh = R16
.filedef curl = R17
.filedef lasth = R18
.filedef lastl = R19
.filedef cph = R20
.filedef cpl = R21

.include "src/mapping/do_data_log.asm"

.equ last_time_data_logged_l_addr = addr
.set addr = addr + 1
.equ last_time_data_logged_h_addr = addr
.set addr = addr + 1
.equ dataInterval = 625 ; 10 ms -> 100 Hz. Giver en teoretisk max datastørrelse på 42 bytes.

ldi R16, 0
sts last_time_data_logged_l_addr, R16
sts last_time_data_logged_h_addr, R16

rjmp data_logger_file_end
log_data_interval:
	push curh
	push curl
	push lasth
	push lastl
	push cph
	push cpl
	in cpl, SREG
	push cpl

	get_time_hl [curh, curl]
	lds lasth, last_time_data_logged_h_addr
	lds lastl, last_time_data_logged_l_addr
	push curh
	push curl
	sub curl, lastl
	sbc curh, lasth
	pop lastl
	pop lasth
	ldi cpl, low(dataInterval)
	ldi cph, high(dataInterval)
	sub cpl, curl
	sbc cph, curh
	brcc log_data_interval_end
	sts last_time_data_logged_l_addr, lastl
	sts last_time_data_logged_h_addr, lasth
	cli
	rcall do_data_log
log_data_interval_end:

	pop cpl
	out SREG, cpl
	pop cpl
	pop cph
	pop lastl
	pop lasth
	pop curl
	pop curh
	ret

data_logger_file_end:
