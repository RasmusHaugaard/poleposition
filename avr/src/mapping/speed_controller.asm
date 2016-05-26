.filedef temp = R16
.filedef desired = R17
.filedef actual = R18

.equ control_speed_status_addr = addr
.set addr = addr + 1

.equ speed_status_disabled = 0
.equ speed_status_keeping_speed = 1
.equ speed_status_accelerating = 2
.equ speed_status_braking = 3

.equ desired_speed_addr = addr
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
 	sub actual, desired
	brcc init_driving_faster_than_desired
init_driving_slower_than_desired:
	send_bt_byte [1]
	ldi temp, speed_status_accelerating
	setspeed [255]
	rjmp init_control_speed_end
init_driving_faster_than_desired:
	send_bt_byte [0]
	ldi temp, speed_status_braking
	brake [20]
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

	cli

	lds desired, desired_speed_addr
	phys_speed [actual]

	lds temp, control_speed_status_addr
	cpi temp, speed_status_disabled
	breq control_speed_end
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
	setspeed [150]
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
	cpi desired, 0xFF
	breq control_full_stop
	sub actual, desired
	brcs control_speed_end
	ldi temp, speed_status_keeping_speed
	sts control_speed_status_addr, temp
	rjmp keep_speed_slower_than_desired
control_full_stop:
	cp actual, desired
	brne control_speed_end
	brake [0]
	disable_control_speed

control_speed_end:
	pop temp
	out SREG, temp
	pop temp
	pop actual
	pop desired

	ret

speed_controller_file_end:
