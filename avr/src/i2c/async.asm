.filedef temp = R16

.equ i2c_status_addr = addr
.set addr = addr + 1

.equ last_twsr = addr
.set addr = addr + 1

.equ i2c_async_sad_addr = addr
.set addr = addr + 1

.equ i2c_async_sub_addr = addr
.set addr = addr + 1

.equ I2C_STATUS_START = 0
.equ I2C_STATUS_SADW = 1
.equ I2C_STATUS_SUB = 2
.equ I2C_STATUS_RESTART = 3
.equ I2C_STATUS_SADR = 4
.equ I2C_STATUS_MAK = 5
.equ I2C_STATUS_DATA = 6

.set saved_pc = PC
.org 0x26
	rjmp twi_handler
.org saved_pc

jmp i2c_async_file_end

.include "src/util/macros/cpi_jmp.asm"

i2c_async_init:
	push temp
	ldi temp, I2C_STATUS_SADW
	sts i2c_status_addr, temp
	I2C_IE_START
	pop temp
	ret

twi_handler:
	rcall i2c_next
	reti

i2c_next:
	push temp
	in temp, SREG
	push temp

	lds temp, i2c_status_addr
	cpi_jmp_eq [temp, I2C_STATUS_SADW, i2c_async_sadw]
	cpi_jmp_eq [temp, I2C_STATUS_SUB, i2c_async_sub]
	cpi_jmp_eq [temp, I2C_STATUS_RESTART, i2c_async_restart]
	cpi_jmp_eq [temp, I2C_STATUS_SADR, i2c_async_sadr]
	cpi_jmp_eq [temp, I2C_STATUS_MAK, i2c_async_mak]
	cpi_jmp_eq [temp, I2C_STATUS_DATA, i2c_async_data]
i2c_inc_status:
	lds temp, i2c_status_addr
	inc temp
	sts i2c_status_addr, temp
i2c_next_end:
	in temp, TWSR
	sts last_twsr, temp
	pop temp
	out SREG, temp
	pop temp
	ret

i2c_async_sadw:
	lds temp, i2c_async_sad_addr
	I2C_IE_SEND [temp]
	rjmp i2c_inc_status

i2c_async_sub:
	lds temp, i2c_async_sub_addr
	I2C_IE_SEND [temp]
	rjmp i2c_inc_status

i2c_async_restart:
	I2C_IE_START
	rjmp i2c_inc_status

i2c_async_sadr:
	lds temp, i2c_async_sad_addr
	inc temp ; sadw -> sadr
	I2C_IE_SEND [temp]
	rjmp i2c_inc_status

i2c_async_mak:
	I2C_IE_MAK
	rjmp i2c_inc_status

i2c_async_data:
	call got_i2c_data
	I2C_ID_STOP
	rjmp i2c_next_end

i2c_async_file_end:
