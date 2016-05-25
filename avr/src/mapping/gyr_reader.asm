.filedef temp = R16
.filedef temp1 = R17

.equ cur_gyr_val_addr = addr
.set addr = addr + 1

.equ gyr_rdy_addr = addr
.set addr = addr + 1

.include "src/i2c/setup.asm"
.include "src/i2c/gyr/setup.asm"
.include "src/i2c/gyr/setup_drdy_int.asm"

ldi temp, 0
sts gyr_rdy_addr, temp
I2C_ID_READ [gyr_addr, gyr_sub_zh, temp]

rjmp gyr_reader_file_end

got_i2c_data:
	rcall gyr_detect_turns
	ret

gyr_reader:
	push temp
	in temp, SREG
	push temp

	lds temp, gyr_rdy_addr
	cpi temp, 1
	breq do_read_i2c
	rjmp gyr_reader_end
do_read_i2c:
	ldi temp, 0
	sts gyr_rdy_addr, temp
	I2C_ID_READ [gyr_addr, gyr_sub_zh, temp]
	push temp1
	ldi temp1, 2
	add temp, temp1
	brvc gyr_offset_no_overflow
	ldi temp, 127
gyr_offset_no_overflow:
	pop temp1
	sts cur_gyr_val_addr, temp
	rcall got_i2c_data
gyr_reader_end:

	pop temp
	out SREG, temp
	pop temp
	ret

gyr_drdy_isr:
	push temp
	ldi temp, 1
	sts gyr_rdy_addr, temp
	pop temp
	reti

gyr_reader_file_end:
