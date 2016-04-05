.include "src/def/m32def.inc"
.include "src/def/data.inc"

.def I2CSR = R25

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/macros/delay.asm"

.org	0x00
	rjmp	init

.org	0x26
	jmp	twint_handler

.org 0x2A ;app_command_handler

.org 0x2C

init:
	ldi I2CSR, 0x00
	ldi R16, 0xFF
	out DDRA, R16
	ldi R16, 0
	out PORTA, R16

	.equ STA0 = 0
	.equ STA1 = 1
	.equ STA2 = 2
	.equ STA3 = 3
	.equ STA4 = 4
	.equ STA5 = 5
	.equ STA6 = 6

	;Frekvensen regnes ud fra 16 MHz og 400 khz = 12.
	.equ	SCL=0b00000110								;Her sættes SCL (Clock frekvensen), ud fra en værdi der bestemmes af CPU clocken.
	.equ	accWadress=0b00111000 						;Adresse til acc for at skrive til den. SDO = GND
	.equ	accRadress=0b00111001 						;Adresse til acc for at læse fra den. SDO = GND
	.equ	accRegisterX=0x29 							;Register adresse for x-værdi
	.equ	accRegisterY=0x2b							;Register adresse for y-værdi
	.equ	accRegisterZ=0x2d 							;Register adresse for z-værdi
	.equ	DataVar = TWDR

	ldi 	R16, (0<<TWPS0) | (0<<TWPS1)					;Fordi vi IKKE bruger prescaler på vores bit rate, sættes disse to værdier til 0.
	out 	TWSR, R16 									;Burde være sat til 0 som deafault.

	ldi 	R16, SCL									;Hastigheden på clocken. Indstilles øverst. Tabelafhængig i forhold til CPU.
	out 	TWBR, R16

	.include	"src/testprograms/int.asm"

	in		R16, TWCR
	ori		R16, (1<<TWIE)
	out 	TWCR, R16	;enable interrupts

	sei

	ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
	out 	TWCR, R16								;indstilling videregives til control register.

	inc		I2CSR									;sætter I2CSR low nibble til 0001

	ldi R16, 1
	out PORTA, R16
	delayms [100]
	ldi R16, 0
	out PORTA, R16
main:
	rjmp	main

twint_handler:
	ldi R18, 1
	out PORTA, R18
	delayms [100]
	reti

	LDI 	R16, 0b00000111
	AND		R16, I2CSR									;Mask'er alt undtageg de tre LSB væk

	CPI		R16, STA0 	 								;Sammenligner status væriderne med den aktuelle status
	brne	notSTA0
	rjmp Status0
notSTA0:
	CPI		R16, STA1
	brne	notSTA1
	rjmp	Status1
notSTA1:
	CPI		R16, STA2
	brne	notSTA2
	rjmp	Status2
notSTA2:
	CPI		R16, STA3
	brne	notSTA3
	rjmp	Status3
notSTA3:
	CPI		R16, STA4
	brne	notSTA4
	rjmp	Status4
notSTA4:
	CPI		R16, STA5
	brne	notSTA5
	rjmp	Status6
notSTA5:
	CPI		R16, STA6
	brne	notSTA6
	rjmp	Status6
notSTA6:
	rjmp error

error:
	ldi 	R16, 1
	out		PORTA, R16
	rjmp 	error

status0:
	;START - Start condition
	ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
	out 	TWCR, R16								;indstilling videregives til control register.

	inc		I2CSR									;sætter I2CSR low nibble til 0001
	reti

Status1:
	;SAD + W - Send slave adresse med write
		ldi		R16, accWadress							;Loader vores accelerometer adresse ind med write, fordi vi skriver.
		out		TWDR, R16								;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) 			;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 								;Dette sendes til control registeret.

	inc		I2CSR								;sætter I2CSR low nibble til 0010

	reti

Status2:
	; SAK - Slave ack bit.
		in 		R16,TWSR 								;Smider vores status register ind i R16
		andi 	R16, 0xF8 								;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x18 								;Sammenligner vores "masking" med hex værdien 18. Hvis de ikke er lig med hinanden, så gå til fejl. 0x18 for SLAQ+W og ACK.
		brne	error

		ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
		out 	TWCR, R16								;indstilling videregives til control register.

	;SUB adrasse - Send register X-adresse med read.
		ldi		R16, accRegisterX						;Loader vores accelerometer adresse ind med READ, fordi vi nu vil læse..
		out		TWDR, R16								;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) 			;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 								;Dette sendes til control registeret.

	inc		I2CSR								;sætter I2CSR low nibble til 0011

	reti

Status3:
	;SAK - Slave ack bit.
		in 		R16,TWSR 								;Smider vores status register ind i R16
		andi 	R16, 0xF8 								;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x28 								;Sammenligner vores "masking" med hex værdien 28. 0x28 for data sendt og ACH modtaget.
		brne	error

	;SR - Repeated Start
		ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
		out 	TWCR, R16								;indstilling videregives til control register.

	inc		I2CSR					;sætter I2CSR low nibble til 0100

	reti

Status4:
	;SAD + R - Slave adresse men nu med wite data.
		ldi		R16, accRadress							;Loader vores accelerometer adresse ind med read, fordi vi læser.
		out		TWDR, R16								;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN)				;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 								;Dette sendes til control registeret.

		inc		I2CSR								;sætter I2CSR low nibble til 0101

	reti

Status5:
	; SAK - Slave ack bit.
		in 		R16,TWSR 								;Smider vores status register ind i R16
		andi 	R16, 0xF8 								;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x40 								;Sammenligner vores "masking" med hex værdien 40. 0x40 er for SLA+R sendt og ACK modtaget.
		brne 	error									;Gå til ERRROR, hvis de to ikke er lig hinanden.

		ldi 	R16, (1<<TWINT) | (1<<TWEN) 			;Alle flag cleares, enabel sættes høj. ACK sendes ikke, fordi vi ikke vil modtage mere.
		out 	TWCR, R16

	inc		I2CSR									;sætter I2CSR low nibble til 0110

	reti

Status6:
	;DATA - 8 bit data fra slaven
	;send_data [accx, R16]
		in R16, DataVar

		rcall sendchar

	;NACK - Not ack bit fra master.
		in 		R16, TWSR 								;Smider vores status register ind i R16
		andi 	R16, 0xF8 								;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x58 								;Sammenligner vores "masking" med hex værdien 58. 0x58 for data modtaget og nack sendt.
		brne 	error 									;Gå til ERRROR, hvis de to ikke er lig hinanden.

		;SP - Stop bit fra master
		ldi 	R16, (1<<TWINT) | (1<<TWEN) | (1<<TWSTO);Alle flag cleares, enabel sættes høj og sender stop signal.
		out 	TWCR, R16

	andi 	I2CSR, 0x10									;sætter I2CSR low nibble til 0000

	reti

sendchar:
	;Er der plads i transmitter buffer?
	sbis UCSRA, UDRE
	;hvis ikke, vent
	rjmp sendchar
	;send R16 til transmitter buffer
	out UDR, R16

	ret
