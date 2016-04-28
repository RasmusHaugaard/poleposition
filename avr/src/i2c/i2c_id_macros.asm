;macroer, der gør det nemt at skrive i2c kode uden interrupts

.filedef temp = R16

.macro I2C_ID_START
	push temp
	ldi temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_STOP
	push temp
	ldi temp, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_NMAK
	push temp
	ldi temp, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_MAK
	push temp
	ldi temp, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_SEND
ERROR Skal bruges med argumenter
.endm

.macro I2C_ID_SEND_i
	push temp
	ldi temp, @0
	out TWDR, temp
	ldi temp, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_SEND_8
	push temp
	out TWDR, @0
	ldi temp, (1<<TWINT)|(1<<TWEN)
	out TWCR, temp
	pop temp
.endm

.macro I2C_ID_WAIT_TWINT
	push temp
I2C_ID_WAIT_TWINT_%:
	in 		temp, TWCR
	sbrs 	temp, TWINT
	rjmp 	I2C_ID_WAIT_TWINT_%
	pop temp
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
