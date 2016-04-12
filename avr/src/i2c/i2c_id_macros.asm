.filedef temp1 = R16

.macro I2C_ID_START
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_STOP
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_NMAK
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_MAK
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_SEND
ERROR Skal bruges med argumenter
.endm

.macro I2C_ID_SEND_i
	push temp1
	ldi temp1, @0
	out TWDR, temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_SEND_8
	push temp1
	out TWDR, @0
	ldi temp1, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_ID_WAIT_TWINT
	push temp1
I2C_ID_WAIT_TWINT_%:
	in 		temp1, TWCR
	sbrs 	temp1, TWINT
	rjmp 	I2C_ID_WAIT_TWINT_%
	pop temp1
.endm

.macro I2C_ID_WRITE
ERROR skal bruges med argumenter
.endm

.macro I2C_ID_WRITE_i_i_i ;@0 = SADW, @1 = SUB, @2 = val
	I2C_ID_START
	I2C_ID_WAIT_TWINT
	I2C_ID_SEND [@0] ;SADW
	I2C_ID_WAIT_TWINT
	I2C_ID_SEND [@1] ;SUB
	I2C_ID_WAIT_TWINT
	I2C_ID_SEND [@2] ;VAL
	I2C_ID_WAIT_TWINT
	I2C_ID_STOP
.endm
