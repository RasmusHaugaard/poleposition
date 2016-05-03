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


.macro I2C_EXPECT_TWSR_i_i_i ; @0 = Expected value 1, @1 other expected value, @2 branch if not equal
	push 	temp
	in 		temp, TWSR
	andi 	temp, 0xF8
	cpi 	temp, @0
	breq	PC + 4
	cpi 	temp, @1
	breq 	PC + 2
	rjmp 	@2
	pop 	temp
.endm

.macro I2C_EXPECT_TWSR_i_i ; @0 = Expected value 1, @1 branch if not equal
	push 	temp
	in 		temp, TWSR
	andi 	temp, 0xF8
	cpi 	temp, @0
	breq	PC + 2
	rjmp 	@1
	pop 	temp
.endm

.macro I2C_EXPECT_TWSR ; @0 = Expected value 1, @1 branch if not equal
ERROR skal bruges med argumenter
.endm

.macro I2C_GET_DATA_8
	in 		@0, TWDR
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

.macro I2C_ID_READ_i_i_i_8 ;@0 = SADR, @1 = SUB, @2 = register
	I2C_ID_START
	I2C_ID_WAIT_TWINT
	I2C_EXPECT_TWSR [$8, $10, ERROR] ;Start eller repeatet start sendt.
	I2C_ID_SEND [@0] ;SADW
	I2C_ID_WAIT_TWINT
	I2C_EXPECT_TWSR [$18, ERROR] ;SLA+W sendt og ACK motaget.
	I2C_ID_SEND [@1] ;SUB
	I2C_ID_WAIT_TWINT
	I2C_EXPECT_TWSR [$28, ERROR] ;DataByte sendt (SUB adresse) og ACK motaget.
	I2C_ID_START 	;REPEATET START
	I2C_ID_WAIT_TWINT
	I2C_EXPECT_TWSR [$10, ERROR] ;Repeatet start sendt
	I2C_ID_SEND [@2] ;SADR
	I2C_ID_WAIT_TWINT
	I2C_EXPECT_TWSR [$40, ERROR] ;SLR+R sendt og ACK modtaget
	I2C_ID_NMAK 	;NACK sendes
	I2C_ID_WAIT_TWINT
	in @3, TWDR 
	I2C_EXPECT_TWSR [$58, ERROR] ;Data motaget og NACK modtaget.
	I2C_ID_STOP
.endm
