.filedef temp = R16
.filedef desired = R17
.filedef actual = R18
.filedef th = R19
.filedef tl = R20
.filedef temp1 = R21
.filedef last_th = R22
.filedef last_tl = R23

.equ control_speed_enabled_addr = addr
.set addr = addr + 1

.equ desired_speed_addr = addr
.set addr = addr + 1

.macro disable_control_speed
	push temp
	ldi temp, 0
	sts control_speed_enabled_addr, temp
	pop temp
.endm

.macro set_control_speed
	.error "Skal kaldes med argument"
.endm

.macro set_control_speed_8
	push tl
	push th
	push temp

	sts desired_speed_addr, @0
	ldi temp, 1
	sts control_speed_enabled_addr, temp

	pop temp
	pop th
	pop tl
.endm

.macro set_control_speed_i
	push temp
	ldi temp, @0
	set_control_speed [temp]
	pop temp
.endm

disable_control_speed
jmp speed_controller_file_end

control_speed:

	push th
	push tl
	push last_th
	push last_tl
	push desired
	push actual
	push temp1
	push temp
	in temp, SREG
	push temp

	lds temp, control_speed_enabled_addr
	cpi temp, 1
	brne control_speed_end
do_control_speed:
	lds desired, desired_speed_addr
	phys_speed [actual]
	sub desired, actual
	brcc driving_faster_than_desired
driving_slower_than_desired:
	setspeed [200]
	rjmp control_speed_end
driving_faster_than_desired:
	setspeed [130]
control_speed_end:

	pop temp
	out SREG, temp
	pop temp
	pop temp1
	pop actual
	pop desired
	pop last_tl
	pop last_th
	pop tl
	pop th

	ret


speed_controller_file_end:
