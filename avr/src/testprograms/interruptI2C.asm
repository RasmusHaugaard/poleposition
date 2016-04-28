.filedef I2CSR = R25
.filedef temp = R16

.equ STA0 = 0
.equ STA1 = 1
.equ STA2 = 2
.equ STA3 = 3
.equ STA4 = 4
.equ STA5 = 5
.equ STA6 = 6
.equ STA7 = 7

;Frekvensen regnes ud fra 16 MHz og 400 khz = 12.
.equ	SCL=0b00000110								;(Clock frekvensen), ud fra en værdi der bestemmes af CPU clocken.
.equ	acc_addr_w = 0b00111000						;Adresse til acc for at skrive til den. SDO = GND
.equ	acc_addr_r = 0b00111001								;Adresse til acc for at læse fra den. SDO = GND
.equ	acc_reg_x = 0x29							;Register adresse for x-værdi
.equ	acc_reg_y = 0x2b							;Register adresse for y-værdi
.equ	acc_reg_z = 0x2d							;Register adresse for z-værdi

.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/macros/delay.asm"
	jmp 0

.org	0x00
	rjmp	init
.org	0x26
	rjmp	twint_handler
.org 0x2A
	rjmp app_command_handler
.org 0x2C

app_command_handler:
	send_bt_byte [49]
	ret

init:
	ldi I2CSR, 0x00
	ldi temp, 0xFF
	out DDRA, temp
	ldi temp, 0
	out PORTA, temp

	ldi 	temp, (0<<TWPS0) | (0<<TWPS1)	;Fordi vi IKKE bruger prescaler på vores bit rate, sættes disse to værdier til 0.
	out 	TWSR, temp						;Burde være sat til 0 som default.

	ldi 	temp, SCL	;Hastigheden på clocken. Indstilles øverst. Tabelafhængig i forhold til CPU.
	out 	TWBR, temp

	send_bt_byte [255]

	.include	"src/testprograms/int.asm"

	sei

	;initialiser kommunikation - resten kører interrupts
	ldi 	temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)	;Forskellige indstillinger sættes.
	out 	TWCR, temp	;indstilling videregives til control register.
	inc		I2CSR	;sætter I2CSR low nibble til 1

main:
	rjmp	main

twint_handler:
	force_send_bt_byte [20]
	ldi R18, 1
	out PORTA, R18
	delayms [100]
	ldi R18, 0
	out PORTA, R18
	delayms [100]

	ldi 	temp, 0b00000111
	and		temp, I2CSR									;Masker alt undtagen de tre LSB væk

	cpi		temp, STA0 	 								;Sammenligner status væriderne med den aktuelle status
	brne	notSTA0
	rjmp Status0
notSTA0:
	cpi		temp, STA1
	brne	notSTA1
	rjmp	Status1
notSTA1:
	cpi		temp, STA2
	brne	notSTA2
	rjmp	Status2
notSTA2:
	cpi		temp, STA3
	brne	notSTA3
	rjmp	Status3
notSTA3:
	cpi		temp, STA4
	brne	notSTA4
	rjmp	Status4
notSTA4:
	cpi		temp, STA5
	brne	notSTA5
	rjmp	Status6
notSTA5:
	cpi		temp, STA6
	brne	notSTA6
	rjmp	Status6
notSTA6:
	cpi		temp, STA7
	brne	notSTA7
	rjmp	Status7
notSTA7:
	rcall err_STA
	reti

err_STA:
	force_send_bt_byte [157]
	delays [1]
	ret

status0:
	force_send_bt_byte [0]
	;START - Start condition
	ldi 	temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)	;Forskellige indstillinger sættes.
	out 	TWCR, temp								;indstilling videregives til control register.

	inc		I2CSR									;sætter I2CSR low nibble til 1
	reti

Status1:
	force_send_bt_byte [1]
	;SAD + W - Send slave adresse med write
	ldi		temp, acc_addr_w							;Loader vores accelerometer adresse ind med write, fordi vi skriver.
	out		TWDR, temp								;Smider værdien fra temp ind i vores dataregsiter.
	ldi 	temp, (1<<TWINT)|(1<<TWEN)|(1<<TWIE) 			;Alle flag cleares og enabel sættes høj.
	out 	TWCR, temp 								;Dette sendes til control registeret.

	inc		I2CSR								;sætter I2CSR low nibble til 2
	reti

Status2:
	force_send_bt_byte [2]
	; SAK - Slave ack bit.
	in 		temp,TWSR	;Smider vores status register ind i temp
	andi 	temp, 0xF8	;"Masking" vores status register med hex værdien F8.
	cpi 	temp, 0x18	;Sammenligner vores "masking" med hex værdien 18. Hvis de ikke er lig med hinanden, så gå til fejl. 0x18 for SLAQ+W og ACK.
	brne 	err_2
	ldi 	temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)	;Forskellige indstillinger sættes.
	out 	TWCR, temp	;indstilling videregives til control register.

	inc		I2CSR
	reti

Status3:
;SUB adrasse - Send register X-adresse med read.
	ldi		temp, acc_reg_x						;Loader vores accelerometer adresse ind med READ, fordi vi nu vil læse..
	out		TWDR, temp								;Smider værdien fra temp ind i vores dataregsiter.
	ldi 	temp, (1<<TWINT)|(1<<TWEN)|(1<<TWIE) 			;Alle flag cleares og enabel sættes høj.
	out 	TWCR, temp 								;Dette sendes til control registeret.

	inc		I2CSR								;sætter I2CSR low nibble til 3
	reti	

err_2:
	force_send_bt_byte [102]
	delays [3]
	rjmp err_2

Status4:
	force_send_bt_byte [3]
	;SAK - Slave ack bit.
	in 		temp,TWSR 								;Smider vores status register ind i temp
	andi 	temp, 0xF8 								;"Masking" vores status register med hex værdien F8.
	cpi 	temp, 0x28 								;Sammenligner vores "masking" med hex værdien 28. 0x28 for data sendt og ACH modtaget.
	brne	err_3

;SR - Repeated Start
	ldi 	temp, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)	;Forskellige indstillinger sættes.
	out 	TWCR, temp								;indstilling videregives til control register.

	inc		I2CSR					;sætter I2CSR low nibble til 0100
	reti

err_3:
	force_send_bt_byte [103]
	force_send_bt_byte [temp]
	delays [50]
	rjmp err_3

Status5:
	force_send_bt_byte [4]
	;SAD + R - Slave adresse men nu med wite data.
	ldi		temp, acc_addr_r							;Loader vores accelerometer adresse ind med read, fordi vi læser.
	out		TWDR, temp								;Smider værdien fra temp ind i vores dataregsiter.
	ldi 	temp, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)				;Alle flag cleares og enabel sættes høj.
	out 	TWCR, temp 								;Dette sendes til control registeret.

	inc		I2CSR								;sætter I2CSR low nibble til 0101
	reti

Status6:
	force_send_bt_byte [5]
	; SAK - Slave ack bit.
	in 		temp,TWSR 								;Smider vores status register ind i temp
	andi 	temp, 0xF8 								;"Masking" vores status register med hex værdien F8.
	cpi 	temp, 0x40 								;Sammenligner vores "masking" med hex værdien 40. 0x40 er for SLA+R sendt og ACK modtaget.
	brne 	err_5									;Gå til ERRROR, hvis de to ikke er lig hinanden.

	ldi 	temp, (1<<TWINT)|(1<<TWEN)|(1<<TWIE) 			;Alle flag cleares, enabel sættes høj. ACK sendes ikke, fordi vi ikke vil modtage mere.
	out 	TWCR, temp

	inc		I2CSR									;sætter I2CSR low nibble til 0110
	reti

err_5:
	force_send_bt_byte [105]
	delays [3]
	rjmp err_5

Status7:
	force_send_bt_byte [6]
	;DATA - 8 bit data fra slaven
	;send_data [accx, temp]
	in temp, TWDR
	rcall sendchar
	;NACK - Not ack bit fra master.
	in 		temp, TWSR 								;Smider vores status register ind i temp
	andi 	temp, 0xF8 								;"Masking" vores status register med hex værdien F8.
	cpi 	temp, 0x58 								;Sammenligner vores "masking" med hex værdien 58. 0x58 for data modtaget og nack sendt.
	brne 	err_6 									;Gå til ERRROR, hvis de to ikke er lig hinanden.
	;SP - Stop bit fra master
	ldi 	temp, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)|(1<<TWIE)
	;Alle flag cleares, enabel sættes høj og sender stop signal.
	out 	TWCR, temp

	andi 	I2CSR, 0x10									;sætter I2CSR low nibble til 0000
	reti

err_6:
	force_send_bt_byte [106]
	delays [3]
	rjmp err_6

sendchar:
	sbis UCSRA, UDRE
	rjmp sendchar
	out UDR, temp
	ret

error:
	cli
	ldi temp, 1
	out PORTA, temp
	rjmp error
