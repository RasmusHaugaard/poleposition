WriteAcc:

;START - Start condition
	startBitSetup:
		ldi 	R16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN)	;Forskellige indstillinger sættes.
		out 	TWCR, R16								;indstilling videregives til control register.

		wait1_xSetup:				;Venter på at TWINT er blevet sat, altså at start bitten er blevet sendt afsted.
			in 		R16,TWCR 	;Vi indlæser control registeret ind i R16.
			sbrs 	R16,TWINT 	;Vi skipper næste handling, hvis TWINT i register 16 er sat.
			rjmp 	wait1_xSetup		;Ellers tjekker vi igen, indtil den er sat.

		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x08 		;Hvis vores "masking" ikke er lig 08 i hex, så gå til fejl. 0x08 er status for start signal.
		brne 	jump1Setup	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	adressWadressSetup

		jump1Setup:
		rjmp	error  		;D0 blinker


;SAD + W - Send slave adresse med write og vent på ack
	adressWadressSetup:
		ldi		R16, accWadress	;Loader vores accelerometer adresse ind med write, fordi vi skriver.
		out		TWDR, R16		;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 		;Dette sendes til control registeret.

		wait2_xSetup:				;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait2_xSetup

; SAK - Slave ack bit.

		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x18 		;Sammenligner vores "masking" med hex værdien 18. Hvis de ikke er lig med hinanden, så gå til fejl. 0x18 for SLAQ+W og ACK.
		brne 	jump2Setup	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	adressWCrtlReg

		jump2Setup:
		rjmp 	error 		;D0 lyser og D1 blinker
;SUB adrasse - Send register adresse med read og vent på ack.

adressWCrtlReg:
		ldi		R16, 0b00100000
		out		TWDR, R16		;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 		;Dette sendes til control registeret.

		wait3_xSetup:				;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait3_xSetup
;SAK - Slave ack bit.
		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x28 		;Sammenligner vores "masking" med hex værdien 28. 0x28 for data sendt og ACH modtaget.
		brne 	jump3Setup	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	dataOutCrtlReg

		jump3Setup:
		rjmp 	error 	;D0 og D1 lyser og D2 blinker
;SAD + W - Data Send
dataOutCrtlReg:
		ldi		R16, 0b11000111
		out		TWDR, R16		;Smider værdien fra R16 ind i vores dataregsiter.
		ldi 	R16, (1<<TWINT) | (1<<TWEN) ;Alle flag cleares og enabel sættes høj.
		out 	TWCR, R16 		;Dette sendes til control registeret.

		wait4_xSetup:				;Samme som wait1. Vi venter på at TWINT bliver sat.
			in 		R16, TWCR
			sbrs	R16, TWINT
			rjmp	wait4_xSetup
;SAK - Slave ack bit.
		in 		R16,TWSR 		;Smider vores status register ind i R16
		andi 	R16, 0xF8 		;"Masking" vores status register med hex værdien F8.
		cpi 	R16, 0x28  		;Sammenligner vores "masking" med hex værdien 28. 0x28 for data sendt og ACH modtaget.
		brne 	jump4Setup	;Gå til ERRROR, hvis de to ikke er lig hinanden.
		rjmp	stop_xSetup

		jump4Setup:
		rjmp 	error 	;D0 og D1 lyser og D2 blinker



;SP - Stop bit fra master.
	stop_xSetup:
		ldi 	R16, (1<<TWINT) | (1<<TWEN) | (1<<TWSTO) ;Alle flag cleares, enabel sættes høj og sender stop signal.
		out 	TWCR, R16

		delayms [100]
