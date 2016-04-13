; Kræver:
; .org 0x26
; rjmp twint_handler

.include "src/i2c/i2c_id_macros.asm"
.include "src/i2c/i2c_ie_macros.asm"

.filedef temp1 = R16
.filedef I2CSR = R17
.filedef I2CSR_P = R18
.filedef I2CSR_SO = R19
.filedef twdrval = R20

.equ DEBUG = 0
.equ CONTINUOS_STREAM = 0

.equ acc_inc_sub = 1
.equ acc_addr_w = 0b00111000
.equ acc_addr_r = 0b00111001
.equ acc_reg_x = 0x29 | (acc_inc_sub<<7)
.equ acc_reg_y = 0x2B | (acc_inc_sub<<7)
.equ acc_reg_z = 0x2D | (acc_inc_sub<<7)
.equ acc_reg_start = acc_reg_x
.equ acc_reg_count = 5
.equ acc_skip_every_2nd = 1

.equ gyr_inc_sub = 1
.equ gyr_addr_w = 0b11010000
.equ gyr_addr_r = 0b11010001
.equ gyr_reg_xl = 0x28 | (gyr_inc_sub<<7)
.equ gyr_reg_xh = 0x29 | (gyr_inc_sub<<7)
.equ gyr_reg_yl = 0x2A | (gyr_inc_sub<<7)
.equ gyr_reg_yh = 0x2B | (gyr_inc_sub<<7)
.equ gyr_reg_zl = 0x2C | (gyr_inc_sub<<7)
.equ gyr_reg_zh = 0x2D | (gyr_inc_sub<<7)
.equ gyr_reg_start = gyr_reg_xh
.equ gyr_reg_count = 5
.equ gyr_skip_every_2nd = 1

.equ I2CSR_DATA_ADDRESS = addr
.set addr = addr + 1

.equ ACCGYR = 7

.equ I2CSR_P_START = 0
.equ I2CSR_P_SADW = 1
.equ I2CSR_P_SUBR = 2
.equ I2CSR_P_RESTART = 3
.equ I2CSR_P_SADR = 4
.equ I2CSR_P_DATA = 5

i2c_start:
	ldi temp1, 12 ;sæt i2c clk til 400 kHz
	out TWBR, temp1

	.include "src/i2c/i2c_setup_acc.asm"
	.include "src/i2c/i2c_setup_gyr.asm"

	ldi I2CSR, 0
	sts I2CSR_DATA_ADDRESS, I2CSR
	rjmp i2c_end

twint_handler:
	rcall I2C_next
	reti

I2C_next:
	lds I2CSR, I2CSR_DATA_ADDRESS
	mov I2CSR_P, I2CSR
	andi I2CSR_P, 0x0F ;Isoler protokol-delen af vores I2C status register
.if DEBUG = 1
	force_send_bt_byte [PS_I2CNEXT]
	force_send_bt_byte [I2CSR]
.endif
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_START, P_START]
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_SADW, P_SADW]
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_SUBR, P_SUBR]
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_RESTART, P_RESTART]
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_SADR, P_SADR]
	cpi_rjmp_eq [I2CSR_P, I2CSR_P_DATA, P_DATA]

	force_send_bt_byte [100] ;Error overflow
	ldi I2CSR, 0
	ret

P_START:
.if acc_reg_count = 0
	rjmp start_gyr
.endif
	I2C_IE_START
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

start_gyr:
	I2C_IE_START
	ldi I2CSR, I2CSR_P_SADW | (1<<ACCGYR)
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SADW:
	ldi temp1, acc_addr_w
	sbrc I2CSR, ACCGYR
	ldi temp1, gyr_addr_w
	I2C_IE_SEND [temp1]
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SUBR:
	ldi temp1, acc_reg_start
	sbrc I2CSR, ACCGYR
	ldi temp1, gyr_reg_start
	I2C_IE_SEND [temp1]
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_RESTART:
	I2C_IE_START
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SADR:
	ldi temp1, acc_addr_r
	sbrc I2CSR, ACCGYR
	ldi temp1, gyr_addr_r
	I2C_IE_SEND [temp1]
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

first_data_entry:
	sbrs I2CSR, ACCGYR
	rjmp AFTER_ACC_RECEIVE
	rjmp AFTER_GYR_RECEIVE

P_DATA:
	mov I2CSR_SO, I2CSR
	swap I2CSR_SO
	andi I2CSR_SO, 0b111 ; mask vores sub address offset
	cpi I2CSR_SO, 0
	breq first_data_entry ;første gang, er der ikke en byte klar endnu
	in temp1, TWDR
	sbrc I2CSR, ACCGYR
	rjmp GYR_RECEIVE
ACC_RECEIVE:
.if acc_skip_every_2nd = 1
	sbrs I2CSR_SO, 0 ;(acc) hvis det er et ulige tal, er der en brugbar værdi
	rjmp AFTER_ACC_RECEIVE
.endif
	force_send_bt_byte [temp1]
AFTER_ACC_RECEIVE:
	cpi I2CSR_SO, acc_reg_count - 1 ; Vi skal sende nmak ved sidste byte.
	breq ask_for_last_byte
	cpi I2CSR_SO, acc_reg_count ; nu har vi modtaget sidste byte.
	breq received_last_byte
	rjmp ask_for_next_byte
GYR_RECEIVE:
.if gyr_skip_every_2nd = 1
	sbrs I2CSR_SO, 0
	rjmp AFTER_GYR_RECEIVE
.endif
	force_send_bt_byte [temp1]
AFTER_GYR_RECEIVE:
	cpi I2CSR_SO, gyr_reg_count - 1 ; Vi skal sende nmak ved sidste byte.
	breq ask_for_last_byte
	cpi I2CSR_SO, gyr_reg_count ; nu har vi modtaget sidste byte.
	breq received_last_byte
	;rjmp ask_for_next_byte
ask_for_next_byte:
	I2C_IE_MAK
	rjmp increment_suboffset
ask_for_last_byte:
	I2C_IE_NMAK
increment_suboffset:
	ldi temp1, 0b10000
	add I2CSR, temp1
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

received_last_byte:
.if gyr_reg_count != 0
	sbrs I2CSR, ACCGYR
	rjmp start_gyr
.endif
.if CONTINUOS_STREAM = 1
	I2C_IE_START
	ldi I2CSR, I2CSR_P_SADW
.else
	I2C_ID_STOP
	ldi I2CSR, I2CSR_P_START
.endif
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

i2c_end:
