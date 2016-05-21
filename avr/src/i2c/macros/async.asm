;macroer, der gør det nemt at skrive i2c kode med interrupts

.filedef temp1 = R16

.macro I2C_IE_START
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
	out TWCR, temp1
	pop temp1
.endm

;STOP udløser ingen interrupt. Brug I2C_ID_STOP

.macro I2C_IE_NMAK
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_IE_MAK
	push temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)|(1<<TWIE)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_IE_SEND
ERROR Skal bruge register eller konstant
.endm

.macro I2C_IE_SEND_i
	push temp1
	ldi temp1, @0
	out TWDR, temp1
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	out TWCR, temp1
	pop temp1
.endm

.macro I2C_IE_SEND_8
	push temp1
	out TWDR, @0
	ldi temp1, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	out TWCR, temp1
	pop temp1
.endm
