.include "src/def/m32def.inc"

.filedef I2CSR = R17
.filedef temp1 = R16

.equ I2C_TWIE = 1 ;enable/disable twi interrupts
.equ DEBUG = 0
.equ CONTINUOS_STREAM = 0

.equ acc_addr_w = 0b00111000 ;Adresse til acc for at skrive til den. SDO = GND
.equ acc_addr_r = 0b00111001 ;Adresse til acc for at læse fra den. SDO = GND
.equ acc_reg_x = 0x29 ;Register adresse for x-værdi
.equ acc_reg_y = 0x2B
.equ acc_reg_z = 0x2D

.equ I2CSR_DATA_ADDRESS = 0x60

.equ I2CSR_START = 0
.equ I2CSR_SADW = 1
.equ I2CSR_SUBR = 2
.equ I2CSR_RESTART = 3
.equ I2CSR_SADR = 4
.equ I2CSR_DATA = 5
.equ I2CSR_STOP = 6

.equ PS_I2CNEXT = 200

.equ ERR_I2CSR_OVERFLOW = 100

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

	ldi temp1, 12 ;sæt i2c clk
	out TWBR, temp1

	rcall I2C_STOP
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
.if DEBUG = 1
	force_send_bt_byte [PS_I2CNEXT]
	force_send_bt_byte [I2CSR]
.endif
	cpi I2CSR, I2CSR_START
	brne not_I2CSR_START
	rcall I2C_START
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_START:
	cpi I2CSR, I2CSR_SADW
	brne not_I2CSR_SADW
	rcall I2C_SADW
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_SADW:
	cpi I2CSR, I2CSR_SUBR
	brne not_I2CSR_SUBR
	rcall I2C_SUBR
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_SUBR:
	cpi I2CSR, I2CSR_RESTART
	brne not_I2CSR_RESTART
	rcall I2C_RESTART
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_RESTART:
	cpi I2CSR, I2CSR_SADR
	brne not_I2CSR_SADR
	rcall I2C_SADR
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_SADR:
	cpi I2CSR, I2CSR_DATA
	brne not_I2CSR_DATA
	rcall I2C_DATA
	inc I2CSR
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_DATA:
	cpi I2CSR, I2CSR_STOP
	brne not_I2CSR_STOP
	rcall I2C_RECEIVE
.if CONTINUOS_STREAM = 1
	rcall I2C_START
	ldi I2CSR, I2CSR_SADW
.else
	rcall I2C_STOP
	ldi I2CSR, I2CSR_START
.endif
	sts I2CSR_DATA_ADDRESS, I2CSR
	ret
not_I2CSR_STOP:
	force_send_bt_byte [ERR_I2CSR_OVERFLOW]
	ldi I2CSR, 0
	ret

I2C_START:
	ldi temp1, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_SADW:
	ldi temp1, acc_addr_w
	out TWDR, temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_SUBR:
	ldi temp1, acc_reg_x
	out TWDR, temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_RESTART:
	ldi temp1, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_SADR:
	ldi temp1, acc_addr_r
	out TWDR, temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_DATA:
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret

I2C_RECEIVE:
	in temp1, TWDR
	force_send_bt_byte [temp1]
	ret

I2C_STOP:
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)|(I2C_TWIE<<TWIE)
	out TWCR, temp1
	ret
