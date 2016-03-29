	.include "src/m32def.inc"

.org	0x0000
	rjmp	init

.org	0x60

init:
	.include "src/setup/stack_pointer.asm"

	ldi R16, 0xFF
	out DDRA, R16
	ldi R16, 0
	out PORTA, R16

	.include "src/setup/bluetooth.asm"

wait_for_conn:
	;Er der en ny byte i receiver buffer?
	;sbis UCSRA, RXC
	;hvis ikke, vent
	;rjmp wait_for_conn

def:
	.equ	err1=0b00000000
	.equ	err2=0b00000001
	.equ	err3=0b00000011
	.equ	err4=0b00000111
	.equ	err5=0b00001111
	.equ	err6=0b00011111
	.equ	err7=0b00111111


	;Frekvensen regnes ud fra 16 MHz og 400 khz = 12.
	.equ	SCL=0b00000110		;Her sættes SCL (Clock frekvensen), ud fra en værdi der bestemmes af CPU clocken.
	.equ	accWadress=0b00111000 ;Adresse til acc for at skrive til den. SDO = GND
	.equ	accRadress=0b00111001 ;Adresse til acc for at læse fra den. SDO = GND
	.equ	accRegisterX=0x2b ;Register adresse for x-værdi
	.equ	accRegisterY=0x2b ;Register adresse for y-værdi
	.equ	accRegisterZ=0x2d ;Register adresse for z-værdi
	.equ	DataVar = TWDR


.macro delay500ms
	ldi 	R16, 16
delay1:
	ldi 	R17, 25
delay2:
	ldi 	R18, 50
delay3:
	nop
	dec	 	R18
	brne	delay3
	nop
	dec	 	R17
	brne	delay2
	nop
	dec		R16
	brne	delay1
.endm

.macro ErrorLoop
ErrorLoop:
		out		PORTA, R19

			delay500ms

		out		PORTA, R20
			delay500ms
		rjmp 	ErrorLoop
.endm

	rjmp	program


;Intialize program
program:

	ldi 	R16, (0<<TWIE)		;Sættes til 0, når vi bruger polling, og ikke interrups. 1 = interrups.
	out 	TWCR, r16

	ldi 	R16, (0<<TWPS0)|(0<<TWPS1)			;Fordi vi IKKE bruger prescaler på vores bit rate, sættes disse to værdier til 0.
	out 	TWSR, R16 			;Burde være sat til 0 som deafault.

	ldi 	R16, SCL			;Hastigheden på clocken. Indstilles øverst. Tabelafhængig i forhold til CPU.
	out 	TWBR, R16

	;ldi 	R16, (0<<PRTWI) 	;Slår power reduction fra so TWI ikke er slået fra.
	;out 	PRR, R16 			;Muligvis RPR i stedet for PRR0


setupAcc:

	.include	"src/testprograms/int.asm"


readAcc:

		ldi		R16, 0b00100001
		out		PORTA, R16

;START - Start condition
	startBit:
		ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
		out 	TWCR, R16								;indstilling videregives til control register.

		wait1_x:				;Venter på at TWINT er blevet sat, altså at start bitten er blevet sendt afsted.
			in 		R16,TWCR 	;Vi indlæser control registeret ind i R16.
			sbrs 	R16,TWINT 	;Vi skipper næste handling, hvis TWINT i register 16 er sat.
			rjmp 	wait1_x		;Ellers tjekker vi igen, indtil den er sat.

		in 		R16, TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x08 		;Hvis vores "masking" ikke er lig 08 i hex, så gå til fejl. 0x08 er status for start signal.
		brne 	jump1	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	adressWadress

		jump1:
		rjmp	Error6  		;D0 blinker

;SAD + W - Send slave adresse med write og vent på ack
	adressWadress:

		ldi		R16, accWadress	;Loader vores accelerometer adresse ind med write, fordi vi skriver.
		out		TWDR, R16		;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 		;Dette sendes til control registeret.

		wait2_x:				;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait2_x

; SAK - Slave ack bit.

		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x18 		;Sammenligner vores "masking" med hex værdien 18. Hvis de ikke er lig med hinanden, så gå til fejl. 0x18 for SLAQ+W og ACK.
		brne 	jump2	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	adressRadressX

		jump2:
		rjmp 	Error2 		;D0 lyser og D1 blinker
;SUB adrasse - Send register adresse med read og vent på ack.

adressRadressX:

		ldi		R16, accRegisterX	;Loader vores accelerometer adresse ind med READ, fordi vi nu vil læse..
		out		TWDR, R16		;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 		;Dette sendes til control registeret.

		wait3_x:				;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait3_x
;SAK - Slave ack bit.
		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x28 		;Sammenligner vores "masking" med hex værdien 28. 0x28 for data sendt og ACH modtaget.
		brne 	jump3	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	restartBit

		jump3:
		rjmp 	Error3 	;D0 og D1 lyser og D2 blinker


;SR - Repear start inden læsning
restartBit:

		ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
		out 	TWCR, R16								;indstilling videregives til control register.

		wait4_x:				;Venter på at TWINT er blevet sat, altså at start bitten er blevet sendt afsted.
			in 		R16,TWCR 	;Vi indlæser control registeret ind i R16.
			sbrs 	R16,TWINT 	;Vi skipper næste handling, hvis TWINT i register 16 er sat.
			rjmp 	wait4_x		;Ellers tjekker vi igen, indtil den er sat.

		in 		R16, TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x10 		;Hvis vores "masking" ikke er lig 10 i hex. 0x10 er status for restart signal.
		brne 	jump4	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	adressRadress

		jump4:
		rjmp 	Error4

;SAD + R - Slave adresse men nu med wite data.
adressRadress:

		ldi		R16, accRadress				;Loader vores accelerometer adresse ind med read, fordi vi læser.
		out		TWDR, R16					;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 					;Dette sendes til control registeret.

		wait5_x:							;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait5_x

; SAK - Slave ack bit.

		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x40 		;Sammenligner vores "masking" med hex værdien 40. 0x40 er for SLA+R sendt og ACK modtaget.
		brne 	jump5	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	dataXvalue

		jump5:
		rjmp 	Error5

;DATA - 8 bit data fra slaven

	dataXvalue:
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares, enabel sættes høj. ACK sendes ikke, fordi vi ikke vil modtage mere.
		out 	TWCR, R16

		wait6_x:
			in 		R16, TWCR	;Vi skal tjekke om TWINT flaget er sat, så vi loader control registeret ind.
			sbrs	R16, TWINT	;Vi tjekker TWINT, og går videre og læser vores data hvis den er sat.
			rjmp	wait6_x 	;Vi Hvis den ikke er sat kigger vi igen.


		rcall sendchar
;NACK - Not ack bit fra master.
		in 		R16, TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x58 		;Sammenligner vores "masking" med hex værdien 58. 0x58 for data modtaget og nack sendt.
		brne 	jump6	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	stop_x

		jump6:
		rjmp 	Error6

;SP - Stop bit fra master.
	stop_x:

		ldi 	R16, (1<<TWINT) | (1<<TWEN) | (1<<TWSTO) ;Alle flag cleares, enabel sættes høj og sender stop signal.
		out 	TWCR, R16

;Færdig
		delay500ms
		ldi		R16,0b00010010
		out		PORTA, R16
		delay500ms

		rjmp	readAcc

Error1:

 		ldi		R19, err1
		ldi		R20, err2
		ErrorLoop
		rjmp 	Error1

Error2:

 		ldi		R19, err2
		ldi		R20, err3
		ErrorLoop
		rjmp	Error2


Error3:

 		ldi		R19, err3
		ldi		R20, err4
		ErrorLoop
		rjmp	Error3

Error4:

 		ldi		R19, err4
		ldi		R20, err5
		ErrorLoop
		rjmp	Error4

Error5:

 		ldi		R19, err5
		ldi		R20, err6
		ErrorLoop
		rjmp	Error5

Error6:

 		ldi		R19, err6
		ldi		R20, err7
		ErrorLoop
		rjmp	Error6

Done:
		ldi		R19, 0b10101010
		ldi		R20, 0b01010101
		ErrorLoop
		rjmp	Done

sendchar:
	in R16, DataVar
	;Er der plads i transmitter buffer?
	sbis UCSRA, UDRE
	;hvis ikke, vent
	rjmp sendchar
	;send R16 til transmitter buffer
	out UDR, R16
	ret
