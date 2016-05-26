.filedef temp = R16
.filedef desired = R17
.filedef actual = R18
.filedef temp1 = R19

.equ control_speed_status_addr = addr
.set addr = addr + 1

.equ speed_status_disabled = 0
.equ speed_status_keeping_speed = 1
.equ speed_status_accelerating = 2
.equ speed_status_braking = 3

.equ desired_speed_addr = addr
.set addr = addr + 1

.equ brake_met_count = 300

.equ brake_met_count_l_addr = addr
.set addr = addr + 1
.equ brake_met_count_h_addr = addr
.set addr = addr + 1

.macro disable_control_speed
	push temp
	ldi temp, speed_status_disabled
	sts control_speed_status_addr, temp
	pop temp
.endm

.macro set_control_speed
	.error "Skal kaldes med argument"
.endm

.macro set_control_speed_8
	sts desired_speed_addr, @0
	rcall init_control_speed
.endm

.macro set_control_speed_i
	push temp
	ldi temp, @0
	set_control_speed [temp]
	pop temp
.endm

disable_control_speed
jmp speed_controller_file_end

init_control_speed:
	push actual
	push desired
	push temp
	in temp, SREG
	push temp

	phys_speed [actual]
	lds desired, desired_speed_addr
 	sub desired, actual
	brcc init_driving_faster_than_desired
init_driving_slower_than_desired:
	setspeed [255]
	ldi temp, speed_status_accelerating
	rjmp init_control_speed_end
init_driving_faster_than_desired:
	ldi temp, 0
	sts brake_met_count_h_addr, temp
	sts brake_met_count_l_addr, temp
	brake [255]
	ldi temp, speed_status_braking
init_control_speed_end:
	sts control_speed_status_addr, temp

	pop temp
	out SREG, temp
	pop temp
	pop desired
	pop actual
	ret

control_speed:
	push desired
	push actual
	push temp
	in temp, SREG
	push temp
	push temp1

	cli

	lds desired, desired_speed_addr
	phys_speed [actual]

	lds temp, control_speed_status_addr
	cpi_jmp_eq [temp, speed_status_disabled, control_speed_end]
	cpi temp, speed_status_keeping_speed
	breq control_keep_speed
	cpi temp, speed_status_accelerating
	breq control_accelerating
	cpi temp, speed_status_braking
	breq control_braking

control_keep_speed:
	sub actual, desired
	brcs keep_speed_faster_than_desired
keep_speed_slower_than_desired:
	setspeed [250]
	rjmp control_speed_end
keep_speed_faster_than_desired:
	setspeed [100]
	rjmp control_speed_end

control_accelerating:
	sub actual, desired
	brcs accelerating_faster_than_desired
	rjmp control_speed_end
accelerating_faster_than_desired:
	ldi temp, speed_status_keeping_speed
	sts control_speed_status_addr, temp
	rjmp keep_speed_faster_than_desired

control_braking:
	cp desired, actual
	breq braking_speed_met
	sub desired, actual
	brcc braking_speed_not_met
braking_speed_met:
	setspeed [0]
	lds temp, brake_met_count_l_addr
	lds temp1, brake_met_count_h_addr
	inc temp
	sts brake_met_count_l_addr, temp
	brne brake_met_count_l_no_overflow
	inc temp1
	sts brake_met_count_h_addr, temp1
brake_met_count_l_no_overflow:
	cpi temp, low(brake_met_count)
	brlo met_count_not_reached
	cpi temp1, high(brake_met_count)
	brlo met_count_not_reached
met_count_reached:
	cpi desired, 0xFF
	brne not_full_stop
met_full_stop:
	disable_control_speed
	setspeed [0]
	rjmp control_speed_end
not_full_stop:
	ldi temp, speed_status_keeping_speed
	sts control_speed_status_addr, temp
	rjmp control_speed_end
met_count_not_reached:
	setspeed [0]
	rjmp control_speed_end
braking_speed_not_met:
	brake [255]
	lds temp, brake_met_count_l_addr
	lds temp1, brake_met_count_h_addr
	dec temp
	brne store
	dec temp1
	breq dont_store
store:
	sts brake_met_count_h_addr, temp1
	sts brake_met_count_l_addr, temp
dont_store:
	rjmp control_speed_end

control_speed_end:
	pop temp1
	pop temp
	out SREG, temp
	pop temp
	pop actual
	pop desired

	ret

speed_controller_file_end:
