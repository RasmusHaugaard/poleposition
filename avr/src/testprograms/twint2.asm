.include "src/def/m32def.inc"

.filedef temp1 = R16
.filedef I2CSR = R17
.filedef I2CSR_P = R18
.filedef I2CSR_SO = R19
.filedef twdrval = R20

.equ acc_inc_sub = 1
.equ acc_addr_w = 0b00111000
.equ acc_addr_r = 0b00111001
.equ acc_reg_x = 0x29 | (acc_inc_sub<<7)
.equ acc_reg_y = 0x2B | (acc_inc_sub<<7)
.equ acc_reg_z = 0x2D | (acc_inc_sub<<7)

.equ gyr_inc_sub = 1
.equ gyr_addr_w = 0b11010000
.equ gyr_addr_r = 0b11010001
.equ gyr_reg_x = 0x29 | (gyr_inc_sub<<7)
.equ gyr_reg_y = 0x2B | (gyr_inc_sub<<7)
.equ gyr_reg_z = 0x2D | (gyr_inc_sub<<7)

.equ I2C_TWIE = 1 ;enable/disable twi interrupts
.equ DEBUG = 0
.equ CONTINUOS_STREAM = 0
.equ acc_reg_start = acc_reg_x
.equ acc_reg_count = 6

.equ I2CSR_DATA_ADDRESS = 0x60

.equ I2CSR_P_START = 0
.equ I2CSR_P_SADW = 1
.equ I2CSR_P_SUBR = 2
.equ I2CSR_P_RESTART = 3
.equ I2CSR_P_SADR = 4
.equ I2CSR_P_DATA = 5

.equ PS_I2CNEXT = 200

.equ ERR_I2CSR_OVERFLOW = 100

.macro I2C_START
	ldi temp1, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
.endm

.macro I2C_STOP
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
.endm

.macro I2C_NMAK
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
.endm

.macro I2C_MAK
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
.endm

.macro I2C_SEND_TWDRVAL
	out TWDR, twdrval
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
.endm

.macro I2C_RECEIVE
	in temp1, TWDR
	force_send_bt_byte [temp1]
.endm

.org LARGEBOOTSTART
	jmp 0x00

.org 0x00
	rjmp init
.org 0x26
	rjmp twint_handler
.org 0x2a
init:
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_setup.asm"
	.include "src/bt/bt_tr_force.asm"
	.include "src/bt/bt_rc_force.asm"
	.include "src/macros/delay.asm"
	.include "src/util/branching.asm"

	ldi temp1, 12 ;sæt i2c clk til 400 kHz
	out TWBR, temp1

	I2C_STOP
	delayms [20]

	force_send_bt_byte [255]
	.include "src/testprograms/int.asm"
	force_send_bt_byte [254]

.if I2C_TWIE = 1
	sei
.endif

	ldi I2CSR, 0
	sts I2CSR_DATA_ADDRESS, I2CSR
	rjmp main

main:
	force_receive_bt_byte
	rcall I2C_next
	rjmp main

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

	force_send_bt_byte [ERR_I2CSR_OVERFLOW]
	ldi I2CSR, 0
	ret

P_START:
	I2C_START
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SADW:
	ldi twdrval, acc_addr_w
	I2C_SEND_TWDRVAL
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SUBR:
	ldi twdrval, acc_reg_start -1
	I2C_SEND_TWDRVAL
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_RESTART:
	I2C_START
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_SADR:
	ldi twdrval, acc_addr_r
	I2C_SEND_TWDRVAL
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

P_DATA:
	mov I2CSR_SO, I2CSR
	swap I2CSR_SO
	andi I2CSR_SO, 0b111
	cpi I2CSR_SO, 0
	breq AFTER_I2C_RECEIVE ;første gang, er der ikke en byte klar endnu
	I2C_RECEIVE
AFTER_I2C_RECEIVE:
	cpi I2CSR_SO, acc_reg_count - 1 ; Skal vi til at be' om sidste byte?
	breq ask_for_last_byte
	cpi I2CSR_SO, acc_reg_count ; nu har vi modtaget sidste byte.
	breq received_last_byte
	I2C_MAK
	ldi temp1, 0b10000
	add I2CSR, temp1
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
ask_for_last_byte:
	I2C_NMAK
	ldi temp1, 0b10000
	add I2CSR, temp1
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret

received_last_byte:
.if CONTINUOS_STREAM = 1
	I2C_START
	ldi I2CSR, I2CSR_P_SADW
.else
	I2C_STOP
	ldi I2CSR, I2CSR_P_START
.endif
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
